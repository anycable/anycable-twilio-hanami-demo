package main

import (
	"fmt"
	"os"

	acli "github.com/anycable/anycable-go/cli"
	"github.com/anycable/twilio-cable/pkg/cli"
	"github.com/anycable/twilio-cable/pkg/config"
	"github.com/anycable/twilio-cable/pkg/version"
	"github.com/joho/godotenv"

	"github.com/apex/log"

	_ "github.com/anycable/anycable-go/diagnostics"
)

func main() {
	conf := config.NewConfig()

	// Try loading env file if any
	_ = godotenv.Load()

	anyconf, err, ok := acli.NewConfigFromCLI(
		os.Args,
		acli.WithCLIName("twilio-cable"),
		acli.WithCLIUsageHeader("TwilioCable, the custom AnyCable-Go build to process Twilio Streams"),
		acli.WithCLIVersion(version.Version()),
		acli.WithCLICustomOptions(cli.CustomOptions(conf)),
	)

	if err != nil {
		log.Fatalf("%v", err)
	}

	if ok {
		os.Exit(0)
	}

	if err := cli.Run(conf, anyconf); err != nil {
		fmt.Fprintf(os.Stderr, "%v", err)
		os.Exit(1)
	}
}
