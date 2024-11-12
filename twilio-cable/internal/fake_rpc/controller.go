package fake_rpc

import (
	"encoding/json"
	"log/slog"

	"github.com/anycable/anycable-go/common"
	"github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/utils"
)

const (
	welcomeMessage = "{\"type\":\"welcome\"}"
)

type Controller struct {
	log *slog.Logger
}

var _ node.Controller = (*Controller)(nil)

func NewController(l *slog.Logger) *Controller {
	return &Controller{log: l.With("context", "fake_rpc")}
}

// Start is no-op
func (c *Controller) Start() error {
	c.log.Warn("using fake RPC controller")
	return nil
}

// Shutdown is no-op
func (c *Controller) Shutdown() error {
	return nil
}

func (c *Controller) Authenticate(sid string, env *common.SessionEnv) (*common.ConnectResult, error) {
	return &common.ConnectResult{
		Status:        common.SUCCESS,
		Identifier:    sid,
		Transmissions: []string{welcomeMessage},
	}, nil
}

func (c *Controller) Subscribe(sid string, env *common.SessionEnv, identifiers string, channel string) (*common.CommandResult, error) {
	res := &common.CommandResult{
		Status:        common.SUCCESS,
		Transmissions: []string{cableMessage("confirm_subscription", channel)},
	}
	return res, nil
}

func (c *Controller) Unsubscribe(sid string, env *common.SessionEnv, identifiers string, channel string) (*common.CommandResult, error) {
	res := &common.CommandResult{
		Status: common.SUCCESS,
	}
	return res, nil
}

func (c *Controller) Perform(sid string, env *common.SessionEnv, id string, channel string, data string) (res *common.CommandResult, err error) {
	var payload map[string]interface{}

	if err = json.Unmarshal([]byte(data), &payload); err != nil {
		return nil, err
	}

	action := payload["action"].(string)

	c.log.Debug("perform", "action", action, "data", payload)

	nextState := make(map[string]string)

	res = &common.CommandResult{
		Status:         common.SUCCESS,
		Disconnect:     false,
		StopAllStreams: false,
		Streams:        nil,
		Transmissions:  []string{},
		IState:         nextState,
	}

	return res, nil
}

func (c *Controller) Disconnect(sid string, env *common.SessionEnv, id string, subscriptions []string) error {
	return nil
}

func cableMessage(typ string, identifier string) string {
	msg := common.Reply{Identifier: identifier, Type: typ}

	return string(utils.ToJSON(msg))
}
