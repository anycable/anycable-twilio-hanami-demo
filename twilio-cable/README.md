# Twilio Cable

Twilio Cable is a service which handles incoming Twilio Stream WebSockets connections and performs speech-to-text analysis.

It uses an AnyCable RPC protocol to comminicate with a Ruby application (to verify and identifiy streams and process transcriptions within the app).

It's a wrapper over [AnyCable-Go][anycable-go] WebSocket server, so, most functionality and configuration is inherited from AnyCable. It's built from the [anycable-go-scaffold](https://github.com/anycable/anycable-go-scaffold) template.

We use open-source speech-to-text server, [Vosk][], which can be launched locally via Docker.
**NOTE:** Vosk can be slow (especially, on M1 MacOS via Docker); we use it only for demonstration purposes. Commercial services (with very similar gRPC APIs 😉) are recommended for production usage.

## Requirements

- Go 1.19+.
- Docker.
- Twilio account.
- Ngrok (or similar) to tunnel Twilio WebSockets to localhost.
- [wsdirector][] to emulate Twilio Streams (without real phone calls)—useful to play with this code without dealing with setting up Twilio/Ngrok.

## Usage

First of all, we need to start Vosk server:

```sh
make vosk-server
```

Just keep it running whily you're playing with the app.

Then, let's start AnyCable server:

```sh
$ make run

INFO 2023-03-08T21:10:30.719Z context=main Starting TwilioCable v0.1.0-4117db3
DEBUG 2023-03-08T21:10:30.719Z context=main 🔧 🔧 🔧 Debug mode is on 🔧 🔧 🔧
INFO 2023-03-08T21:10:30.719Z context=main Starting AnyCable 1.3.0 (pid: 23406, open file limit: 122880, gomaxprocs: 8)
DEBUG 2023-03-08T21:10:30.719Z context=disconnector Calls rate: 10ms
INFO 2023-03-08T21:10:30.720Z context=rpc RPC controller initialized: localhost:50051 (concurrency: 28, enable_tls: false, proto_versions: v1)
INFO 2023-03-08T21:10:30.720Z context=main Handle WebSocket connections at http://localhost:8080/cable
INFO 2023-03-08T21:10:30.720Z context=main Handle Twilio Streams WebSocket connections at ws://localhost:8080/streams
# ...
```

By default, the real RPC controller is used (i.e., we will call an RPC app via gRPC). Sometimes it's useful to make it possible to run a WebSocket server in isolation; for that, we can use a _fake_ RPC controller (which just prints commands to the console):

```sh
$ FAKE_RPC=1 make run

...
WARN 2023-03-08T21:22:10.269Z context=fake_rpc Using fake RPC controller
...
```

It's especiially useful when testing the app locally with wsdirector (see below).

## Using wsdirector

You can use WebSocket samples with audio bytes to emulate calls to Twilio.

```shell
wsdirector -f etc/fixtures/wsdirector/sample.yml -u ws://localhost:8080/streams
```

We have a collection of audio samples in `etc/fixtures/wsdirector/`. You can use any of them.

- capitals.yml
- london.yml
- ruby.yml
- sample.yml

## Real phone calls

First, you need to create a Twilio account, buy a phone number and populate the `etc/.env` file with the required configuration parameters (see `etc/.env.sample`).

Then, to test the app with real phone calls locally, you must configure a tunnel to receive WebSocket connections. You can use [Ngrok][] for that:

```sh
ngrok http --region=us localhost:8080
```

Then, in the configuration of the Ruby app (`.env`), update the value of the `TWILIO_CABLE_URL` to your Ngrok domain:

```sh
TWILIO_CABLE_URL=wss://YOUR_DOMAIN/cable # YOUR_DOMAIN from ngrok command
```

Now you can make a test call by running:

```sh
make call
```

Pick up your phone and tell something to the robot 🤖.

## Development

**NOTE:** Make sure Go 1.19+ installed.

The following commands are available:

```shell
# Build the Go binary (will be available in dist/twilio-anycable)
make

# Run Golang tests
make test
```

We use [golangci-lint](https://golangci-lint.run) to lint Go source code:

```sh
make lint
```

### Git hooks

To automatically lint and test code before commits/pushes it is recommended to install [Lefthook][lefthook]:

```sh
brew install lefthook

lefthook install
```

[anycable-go]: https://github.com/anycable/anycable-go
[lefthook]: https://github.com/evilmartians/lefthook
[wsdirector]: https://github.com/palkan/wsdirector
[Ngrok]: https://ngrok.com
[Vosk]: https://github.com/alphacep/vosk-server
