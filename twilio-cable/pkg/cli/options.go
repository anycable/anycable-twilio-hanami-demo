package cli

import (
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/urfave/cli/v2"
)

func CustomOptions(conf *config.Config) func() ([]cli.Flag, error) {
	return func() ([]cli.Flag, error) {
		return []cli.Flag{
				&cli.BoolFlag{
					Category:    "MISC",
					Name:        "fake_rpc",
					EnvVars:     []string{"FAKE_RPC"},
					Destination: &conf.FakeRPC,
					Value:       conf.FakeRPC,
				},
			},
			nil
	}
}
