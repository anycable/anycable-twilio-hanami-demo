# Twilio Cable

Twilio Cable is a service which handles incoming Twilio Stream WebSockets connections and performs some processing of audo packets.

It uses an AnyCable RPC protocol to comminicate with a Ruby application (to verify and identifiy streams and process streams information within the app).

It's a wrapper over [AnyCable-Go][anycable-go] WebSocket server, so, most functionality and configuration is inherited from AnyCable. It's built from the [anycable-go-scaffold](https://github.com/anycable/anycable-go-scaffold) template.

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
