# Kaisen

This is an example Hanami 2.0 application, which demonstrates who [AnyCable][] can be used to work with Twilio phone call streams.

The app also acts as a playground for the following purposes:

- Using [Phlex][] as a (yet-missing) view layer for Hanami.
- Using [Vite Ruby][] as assets bundler.

## Usage

First, install dependencies:

```sh
bundle install

yarn install
```

We recommend using a process manager (like [Hivemind][]) to run all the required proceses:

```ruby
hivemind Procfile.dev
```

Alternatively, you can all the processes independently:

```sh
# Hanami server
bundle exec hanami server

# Assets server (optional)
bin/vite dev
```

[AnyCable]: https://anycable.io
[Phlex]: https://www.phlex.fun
[Vite Ruby]: https://vite-ruby.netlify.app
[Hivemind]: https://github.com/DarthSim/hivemind
