package streamer

import (
	"context"
	"sync"

	"github.com/apex/log"

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

type Streamer struct {
	config             *config.Config
	sendResultFunction streamCallback

	cancelFn context.CancelFunc
	closed   bool
	closedMu sync.Mutex

	log *log.Entry
}

func NewStreamer(c *config.Config) *Streamer {
	return &Streamer{
		config:   c,
		cancelFn: func() {},
		log:      log.WithField("context", "streamer"),
	}
}

func (t *Streamer) Push(msg *Packet) error {
	res := NewResponse(msg)

	t.sendResultFunction(res)

	return nil
}

func (t *Streamer) OnResponse(fn streamCallback) {
	t.sendResultFunction = fn
}

func (t *Streamer) Close() {
	t.closedMu.Lock()
	defer t.closedMu.Unlock()

	t.closed = true
	t.cancelFn()
}
