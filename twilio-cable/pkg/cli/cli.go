package cli

import (
	"net/http"

	acli "github.com/anycable/anycable-go/cli"
	aconfig "github.com/anycable/anycable-go/config"
	"github.com/anycable/anycable-go/metrics"
	"github.com/anycable/anycable-go/node"
	"github.com/anycable/anycable-go/pubsub"
	"github.com/anycable/anycable-go/ws"
	"github.com/apex/log"
	"github.com/gorilla/websocket"

	"github.com/anycable/twilio-cable/internal/fake_rpc"
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/anycable/twilio-cable/pkg/custom"
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

// NoopSubscriber is used to stub AnyCable pub/sub functionality
type NoopSubscriber struct{}

var _ pubsub.Subscriber = (*NoopSubscriber)(nil)

func (NoopSubscriber) Start(done chan error) (err error) { return }
func (NoopSubscriber) Shutdown() (err error)             { return }

func initAnyCableRunner(appConf *config.Config, anyConf *aconfig.Config) (*acli.Runner, error) {
	opts := []acli.Option{
		acli.WithName("AnyCable"),
		acli.WithSubscriber(func(h pubsub.Handler, c *aconfig.Config) (pubsub.Subscriber, error) {
			return &NoopSubscriber{}, nil
		}),
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
		extractor := ws.DefaultHeadersExtractor{Headers: c.Headers, Cookies: c.Cookies}

		executor := custom.NewExecutor(n)

		log.WithField("context", "main").Infof("Handle Twilio Streams WebSocket connections at ws://%s:%d/streams", c.Host, c.Port)

		return ws.WebsocketHandler([]string{}, &extractor, &c.WS, func(wsc *websocket.Conn, info *ws.RequestInfo, callback func()) error {
			wrappedConn := ws.NewConnection(wsc)
			session := node.NewSession(n, wrappedConn, info.URL, info.Headers, info.UID)
			session.SetEncoder(custom.Encoder{})
			session.SetExecutor(executor)

			_, err := n.Authenticate(session)

			if err != nil {
				return err
			}

			return session.Serve(callback)
		}), nil
	}
}
