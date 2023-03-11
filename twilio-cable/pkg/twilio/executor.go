package twilio

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/anycable/anycable-go/common"
	"github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/utils"
	"github.com/anycable/anycable-go/ws"

	"github.com/anycable/twilio-cable/internal/g711"
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/anycable/twilio-cable/pkg/streamer"
)

// The name of the Action Cable channel class to handle actions
const channelName = "twilio"

// Handling Twilio events and transforming them into Action Cable commands
type Executor struct {
	node node.AppNode
	conf *config.Config
}

var _ node.Executor = (*Executor)(nil)

func NewExecutor(node node.AppNode, c *config.Config) *Executor {
	return &Executor{node: node, conf: c}
}

func (ex *Executor) HandleCommand(s *node.Session, msg *common.Message) error {
	if msg.Command == ConnectedEvent {
		if s.Connected {
			return errors.New("Already connected")
		}

		s.Connected = true
		return nil
	}

	if msg.Command == StopEvent {
		s.Log.Debugf("Stop received. Disconnecting")
		s.Disconnect("stream stopped", ws.CloseNormalClosure)
		return nil
	}

	if !s.Connected {
		return errors.New("Must be connected before receiving commands")
	}

	// That's the first message with some additional information.
	// Here we should perform authentication (#kick_off)
	if msg.Command == StartEvent {
		start, ok := msg.Data.(StartPayload)

		s.Log.Debugf("Incoming start message: %s", start)

		if !ok {
			return fmt.Errorf("Malformed start message: %v", msg.Data)
		}

		s.InternalState = make(map[string]interface{})
		s.InternalState["callSid"] = start.CallSID

		// We add account SID as a header to the sesssion.
		// So, we can access it via request.headers['x-twilio-account'] in Ruby.
		s.GetEnv().SetHeader("x-twilio-account", start.AccountSID)
		res, err := ex.node.Authenticate(s)

		if res != nil && res.Status == common.FAILURE {
			return nil
		}

		if err != nil {
			return err
		}

		// We need to perform an additional RPC call to initialize the channel subscription
		_, err = ex.node.Subscribe(s, &common.Message{Identifier: channelId(start.CallSID), Command: "subscribe"})

		if err != nil {
			return err
		}

		err = ex.initStreamer(s, start.CallSID)

		if err != nil {
			return err
		}

		return err
	}

	if msg.Command == MediaEvent {
		twilioMsg := msg.Data.(MediaPayload)

		// Ignore robot streams
		if twilioMsg.Track == "outbound" {
			return nil
		}

		var t *streamer.Streamer

		if rawStreamer, ok := s.InternalState["streamer"]; ok {
			t = rawStreamer.(*streamer.Streamer)
		}

		if t == nil {
			return errors.New("no streamer configured")
		}

		audioBytes, err := base64.StdEncoding.DecodeString(twilioMsg.Payload)

		if err != nil {
			return err
		}

		// Vosk only understands PCM, but Twilio sends x-mulaw; so we need to do some conversion
		err = t.Push(&streamer.Packet{Audio: g711.DecodeUlaw(audioBytes), Track: twilioMsg.Track})

		return err
	}

	if msg.Command == MarkEvent {
		s.Log.Debugf("Mark received: %v", msg.Data)
		return nil
	}

	return fmt.Errorf("Unknown command: %s", msg.Command)
}

func (ex *Executor) Disconnect(s *node.Session) error {
	var t *streamer.Streamer

	if rawStreamer, ok := s.InternalState["streamer"]; ok {
		t = rawStreamer.(*streamer.Streamer)
	}

	if t != nil {
		t.Close()
	}

	return ex.node.Disconnect(s)
}

func (ex *Executor) initStreamer(s *node.Session, sid string) error {
	identifier := channelId(sid)

	st := streamer.NewStreamer(ex.conf)

	st.OnResponse(func(response *streamer.Response) {
		_, performError := ex.node.Perform(s, &common.Message{
			Identifier: identifier,
			Command:    "message",
			Data: string(
				utils.ToJSON(map[string]interface{}{
					"action": "handle_message",
					"result": response,
				})),
		})

		if performError != nil {
			s.Log.Errorf("Failed to send response: %v", performError)
		}

		s.Log.Debugf("Response sent: %v", string(utils.ToJSON(response)))
	})

	err := st.KickOff(context.Background())

	if err != nil {
		return err
	}

	s.InternalState["streamer"] = st

	return nil
}

func channelId(sid string) string {
	msg := struct {
		Channel string `json:"channel"`
		Sid     string `json:"sid"`
	}{Channel: channelName, Sid: sid}

	b, err := json.Marshal(msg)

	if err != nil {
		panic("Failed to build channel identifier 😲")
	}

	return string(b)
}
