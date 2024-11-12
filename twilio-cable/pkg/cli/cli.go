package cli

import (
	"fmt"
	"log/slog"
	"net/http"

	acli "github.com/anycable/anycable-go/cli"
	aconfig "github.com/anycable/anycable-go/config"
	"github.com/anycable/anycable-go/logger"
	"github.com/anycable/anycable-go/metrics"
	"github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/server"
	"github.com/anycable/anycable-go/ws"
	"github.com/gorilla/websocket"

	"github.com/anycable/twilio-cable/internal/fake_rpc"
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/anycable/twilio-cable/pkg/twilio"
	"github.com/anycable/twilio-cable/pkg/version"
)

func Run(conf *config.Config, anyconf *aconfig.Config) error {
	// Configure your logger here
	logHandler, err := logger.InitLogger(anyconf.Log.LogFormat, anyconf.Log.LogLevel)
	if err != nil {
		return err
	}

	log := slog.New(logHandler)
	anycable, err := initAnyCableRunner(conf, anyconf)

	if err != nil {
		return err
	}

	log.Info(fmt.Sprintf("Starting TwilioCable v%s", version.Version()))

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
		opts = append(opts, acli.WithController(func(m *metrics.Metrics, c *aconfig.Config, lg *slog.Logger) (node.Controller, error) {
			return fake_rpc.NewController(lg), nil
		}))
	} else {
		opts = append(opts, acli.WithDefaultRPCController())
	}

	return acli.NewRunner(anyConf, opts)
}

func twilioWebsocketHandler(config *config.Config) func(n *node.Node, c *aconfig.Config, lg *slog.Logger) (http.Handler, error) {
	return func(n *node.Node, c *aconfig.Config, lg *slog.Logger) (http.Handler, error) {
		extractor := server.DefaultHeadersExtractor{Headers: c.RPC.ProxyHeaders, Cookies: c.RPC.ProxyCookies}

		executor := twilio.NewExecutor(n, config)

		lg.Info(fmt.Sprintf("Handle Twilio Streams WebSocket connections at ws://%s:%d/streams", c.Server.Host, c.Server.Port))
		lg.Info(fmt.Sprintf("Use Vosk server at %s (partial: %v)", config.VoskRPC, config.PartialRecognize))

		return ws.WebsocketHandler([]string{}, &extractor, &c.WS, lg, func(wsc *websocket.Conn, info *server.RequestInfo, callback func()) error {
			wrappedConn := ws.NewConnection(wsc)
			session := node.NewSession(
				n, wrappedConn, info.URL, info.Headers, info.UID,
				node.WithEncoder(twilio.Encoder{}), node.WithExecutor(executor),
			)

			return session.Serve(callback)
		}), nil
	}
}
