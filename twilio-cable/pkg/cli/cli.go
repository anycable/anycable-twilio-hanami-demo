package cli

import (
	"net/http"

	acli "github.com/anycable/anycable-go/cli"
	aconfig "github.com/anycable/anycable-go/config"
	"github.com/anycable/anycable-go/metrics"
	"github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/server"
	"github.com/anycable/anycable-go/ws"
	"github.com/apex/log"
	"github.com/gorilla/websocket"

	"github.com/anycable/twilio-cable/internal/fake_rpc"
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/anycable/twilio-cable/pkg/twilio"
	"github.com/anycable/twilio-cable/pkg/version"
)

func Run(conf *config.Config, anyconf *aconfig.Config) error {
	anycable, err := initAnyCableRunner(conf, anyconf)

	if err != nil {
		return err
	}

	log.WithField("context", "main").Infof("Starting TwilioCable v%s", version.Version())

	return anycable.Run()
}

func initAnyCableRunner(appConf *config.Config, anyConf *aconfig.Config) (*acli.Runner, error) {
	opts := []acli.Option{
		acli.WithName("AnyCable"),
		acli.WithDefaultSubscriber(),
		acli.WithDefaultBroker(),
		acli.WithDefaultBroadcaster(),
		acli.WithWebSocketEndpoint("/streams", twilioWebsocketHandler(appConf)),
	}

	if appConf.FakeRPC {
		opts = append(opts, acli.WithController(func(m *metrics.Metrics, c *aconfig.Config) (node.Controller, error) {
			return fake_rpc.NewController(), nil
		}))
	} else {
		opts = append(opts, acli.WithDefaultRPCController())
	}

	return acli.NewRunner(anyConf, opts)
}

func twilioWebsocketHandler(config *config.Config) func(n *node.Node, c *aconfig.Config) (http.Handler, error) {
	return func(n *node.Node, c *aconfig.Config) (http.Handler, error) {
		extractor := server.DefaultHeadersExtractor{Headers: c.Headers, Cookies: c.Cookies}

		executor := twilio.NewExecutor(n, config)

		log.WithField("context", "main").Infof("Handle Twilio Streams WebSocket connections at ws://%s:%d/streams", c.Host, c.Port)
		log.WithField("context", "streamer").Infof("Use Vosk server at %s (partial: %v)", config.VoskRPC, config.PartialRecognize)

		return ws.WebsocketHandler([]string{}, &extractor, &c.WS, func(wsc *websocket.Conn, info *server.RequestInfo, callback func()) error {
			wrappedConn := ws.NewConnection(wsc)
			session := node.NewSession(
				n, wrappedConn, info.URL, info.Headers, info.UID,
				node.WithEncoder(twilio.Encoder{}), node.WithExecutor(executor),
			)

			return session.Serve(callback)
		}), nil
	}
}
