package twilio

import (
	"strconv"
	"testing"

	"github.com/anycable/anycable-go/common"
	anode "github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/node_mocks"
	"github.com/apex/log"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

func TestHandleCommandConnected(t *testing.T) {
	node := &node_mocks.AppNode{}
	executor := NewExecutor(node)

	t.Run("when not connected", func(t *testing.T) {
		session := buildSession(false)

		err := executor.HandleCommand(session, &common.Message{Command: ConnectedEvent})

		require.NoError(t, err)
		assert.True(t, session.Connected)
	})

	t.Run("when already connected", func(t *testing.T) {
		session := buildSession(true)

		err := executor.HandleCommand(session, &common.Message{Command: ConnectedEvent})

		require.Error(t, err)
		assert.Equal(t, "Already connected", err.Error())
	})
}

func TestHandleCommandStart(t *testing.T) {
	node := &node_mocks.AppNode{}
	executor := NewExecutor(node)

	t.Run("when not connected", func(t *testing.T) {
		session := buildSession(false)

		err := executor.HandleCommand(session, &common.Message{Command: StartEvent})

		require.Error(t, err)
		assert.Equal(t, "Must be connected before receiving commands", err.Error())
	})

	t.Run("calls Authenticate with a header and subscribes", func(t *testing.T) {
		session := buildSession(true)

		start := StartPayload{AccountSID: "ac42"}

		// We should call authenticate
		node.On("Authenticate", session).Return(&common.ConnectResult{Status: common.SUCCESS}, nil).Run(func(args mock.Arguments) {
			s := args.Get(0).(*anode.Session)
			headers := (*s.GetEnv().Headers)
			val, ok := headers["x-twilio-start"]

			if !ok {
				require.True(t, ok, "Header is missing")
			}

			b, err := start.ToJSON()

			require.NoError(t, err)

			require.Equal(t, string(b), val)
		})

		// And also subscribe to a channel (in authenticate passes)
		node.
			On("Subscribe", session, &common.Message{Identifier: channelId("s123"), Command: "subscribe"}).
			Return(nil, nil)

		err := executor.HandleCommand(session, &common.Message{
			Identifier: "s123",
			Command:    StartEvent,
			Data:       start,
		})

		require.NoError(t, err)

		// Make sure we do not keep header in the state
		assert.Equal(t, "", (*session.GetEnv().Headers)["x-twilio-start"])
		// Make sure we keep streamer in the internal state
		assert.NotNil(t, session.InternalState["streamer"])
	})
}

func TestHandleCommandMedia(t *testing.T) {
	node := &node_mocks.AppNode{}
	executor := NewExecutor(node)

	t.Run("when not connected", func(t *testing.T) {
		session := buildSession(false)

		err := executor.HandleCommand(session, &common.Message{Command: MediaEvent})

		require.Error(t, err)
		assert.Equal(t, "Must be connected before receiving commands", err.Error())
	})
}

func TestHandleCommandMark(t *testing.T) {
	node := &node_mocks.AppNode{}
	executor := NewExecutor(node)

	t.Run("when not connected", func(t *testing.T) {
		session := buildSession(false)

		err := executor.HandleCommand(session, &common.Message{Command: MarkEvent})

		require.Error(t, err)
		assert.Equal(t, "Must be connected before receiving commands", err.Error())
	})

	t.Run("returns no error", func(t *testing.T) {
		session := buildSession(true)

		err := executor.HandleCommand(session, &common.Message{Command: MarkEvent})

		require.NoError(t, err)
	})
}

var (
	sessionCounter = 1
)

func buildSession(connected bool) *anode.Session {
	sessionCounter++
	s := anode.Session{
		Connected: connected,
		Log:       log.WithField("context", "test"),
	}
	s.SetID(strconv.Itoa(sessionCounter))
	s.SetEncoder(Encoder{})
	s.SetEnv(common.NewSessionEnv("ws://anycable.io/twilio", nil))
	return &s
}
