# AnyCable + Twilio Media Streams + Hanami

This repository contains example applications demonstrating how to build phone calls processing pipelines with [Twilio Media Streams][], [AnyCable-Go][] and Ruby ([Hanami][]).

The example application peforms speech recognition (via [Vosk][]) and shows results in a web browser.

TODO: Add screenshot/video.

## Quick start (w/ Twilio)

First, start all the components:

- Start Ngrok: `ngrok http 8080`.
- Start Hanami application with NGrok url provided: `cd kaisen && TWILIO_CABLE_URL=https://<some-id>.ngrok.io hanami server`.
- Start Vosk server: `cd twilio-anycable && make vosk-server` (you can use the fake server, too, see below).
- Start AnyCable server: `cd twilio-anycable && make run`.

Now, open a browser at [localhost:2300](http://localhost:2300), type in your phone number into the form and click "Call". Wait for the call, pick up the phone, and start talking—the logs should appear in the browser!

## Very quick start (no Twilio, no Docker)

You can play with this application without Twilio access by emulating media streams via [wsdirector][].

First, start all the components:

- Start Hanami application: `cd kaisen && hanami server`.
- Start Vosk fake server: `cd twilio-anycable && make vosk-fake-server`.
- Start AnyCable server: `cd twilio-anycable && make run`.

Now, you can emulate a phone call and watch the real-time logs in the browser:

- Open [localhost:2300](http://localhost:2300)
- Run wsdirector: `cd twilio-anycable && make wsdirector`.

See the logs in the browser!

[Twilio Media Streams]: https://www.twilio.com/docs/voice/api/media-streams
[AnyCable-Go]: https://github.com/anycable/anycable-go
[Hanami]: https://hanamirb.org
[wsdirector]: https://github.com/palkan/wsdirector
[Vosk]: https://github.com/alphacep/vosk-server
