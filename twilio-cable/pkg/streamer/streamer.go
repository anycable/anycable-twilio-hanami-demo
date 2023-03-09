package streamer

import (
	"bytes"
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/apex/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"

	"github.com/anycable/twilio-cable/internal/vosk"
	"github.com/anycable/twilio-cable/pkg/config"
)

type Packet struct {
	Audio []byte
	Track string
}

type Result struct {
	Text string
}

type streamCallback = func(response *Response)

// Streamer is responsible for accumulating audio packets, sending them to the recognition service via gRPC
// and sending results back to the executor (via a callback)
// NOTE: This implementation is not meant for production. You shouldn't create a gRPC client per session,
// and instead use a single one.
type Streamer struct {
	config             *config.Config
	sendResultFunction streamCallback

	conn   *grpc.ClientConn
	client vosk.SttServiceClient
	stream vosk.SttService_StreamingRecognizeClient

	waitResults time.Duration

	buf *bytes.Buffer

	cancelFn context.CancelFunc
	closed   bool
	mu       sync.Mutex

	log *log.Entry
}

const (
	// 320 is the number of bytes in a single packet (20ms),
	// thus, flush every 300ms
	bytesPerFlush = 320 * 15
)

func NewStreamer(c *config.Config) *Streamer {
	return &Streamer{
		config:      c,
		waitResults: time.Duration(c.WaitResults) * time.Second,
		buf:         bytes.NewBuffer(nil),
		cancelFn:    func() {},
		log:         log.WithField("context", "streamer"),
	}
}

func (s *Streamer) KickOff(ctx context.Context) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	cancelCtx, cancel := context.WithCancel(ctx)

	s.cancelFn = cancel

	const grpcServiceConfig = `{"loadBalancingPolicy":"round_robin"}`

	dialOptions := []grpc.DialOption{
		grpc.WithDefaultServiceConfig(grpcServiceConfig),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	}

	conn, err := grpc.Dial("localhost:5001", dialOptions...)

	if err != nil {
		return err
	}

	s.conn = conn
	s.client = vosk.NewSttServiceClient(conn)

	stream, err := s.client.StreamingRecognize(cancelCtx)
	if err != nil {
		return err
	}

	if err := stream.Send(&vosk.StreamingRecognitionRequest{
		StreamingRequest: &vosk.StreamingRecognitionRequest_Config{
			Config: &vosk.RecognitionConfig{
				Specification: &vosk.RecognitionSpec{
					SampleRateHertz: 8000,
					PartialResults:  s.config.PartialRecognize,
				},
			},
		},
	}); err != nil {
		return fmt.Errorf("failed to configure stream: %v", err)
	}

	s.stream = stream

	go s.readFromStream()

	return nil
}

func (s *Streamer) Push(msg *Packet) error {
	s.buf.Write(msg.Audio)

	if s.buf.Len() > bytesPerFlush {
		if err := s.stream.Send(&vosk.StreamingRecognitionRequest{
			StreamingRequest: &vosk.StreamingRecognitionRequest_AudioContent{
				AudioContent: s.buf.Bytes(),
			},
		}); err != nil {
			return fmt.Errorf("could not send audio: %v", err)
		}

		s.buf.Reset()
	}

	return nil
}

func (s *Streamer) OnResponse(fn streamCallback) {
	s.sendResultFunction = fn
}

func (s *Streamer) Close() {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.closed = true

	// Do not close the stream right away, since resaults are still could
	// be processing
	time.AfterFunc(s.waitResults, s.cancelFn)
}

func (s *Streamer) readFromStream() {
	for {
		resp, err := s.stream.Recv()

		if err == nil {
			chunks := resp.GetChunks()
			if len(chunks) != 0 {
				chunk := chunks[0]

				alt := chunk.Alternatives[0]

				if alt.Text == "" && chunk.Final {
					s.log.Debugf("recognition completed")
					break
				}

				if alt.Text != "" {
					s.sendResultFunction(&Response{Message: alt.Text, Final: chunk.Final, Event: "transcript"})
				}
			}
		} else {
			st, ok := status.FromError(err)
			if !ok {
				s.log.Errorf("recognize error: %v", err)
				s.sendResultFunction(&Response{Message: err.Error(), Event: "error"})
			} else {
				code := st.Code()

				if code == codes.Canceled {
					s.sendResultFunction(&Response{Message: "Too slow recognition, I'm sorry", Event: "error"})
				} else {
					s.sendResultFunction(&Response{Message: err.Error(), Event: "error"})
				}
			}

			break
		}
	}

	s.conn.Close()
}
