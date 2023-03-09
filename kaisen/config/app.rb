# frozen_string_literal: true

require "hanami"

require "phlex"
require "vite_ruby"

require "anycable"
require "litecable"

require "dry/monads"
require "dry/monads/do"

require "anyway/hanami"
Anyway.loaders.append :hanami, Anyway::Hanami::Loader

require "cable_ready/hanami"

module Kaisen
  class App < Hanami::App
    environment :production do
      config.middleware.use Rack::Static, { urls: ["/vite/"], root: "public" }
    end

    environment :test do
      config.middleware.use Rack::Static, { urls: ["/vite-test/"], root: "public" }
    end

    environment :development do
      config.middleware.use(ViteRuby::DevServerProxy) if ViteRuby.run_proxy?
      config.middleware.use Rack::Static, { urls: ["/vite-dev/"], root: "public" }

      # Allow @vite/client to hot reload changes in development
      config.actions.content_security_policy[:script_src] += " 'unsafe-eval' 'unsafe-inline'"
      config.actions.content_security_policy[:connect_src] += " ws://#{ ViteRuby.config.host_with_port }"
      config.actions.content_security_policy[:style_src] += " 'unsafe-eval'"

      # FIXME: Is there a way to read the value from settings?
      config.actions.content_security_policy[:connect_src] += " ws://localhost:8080"

      AnyCable.capture_exception do |ex|
        Hanami.app["logger"].error("#{ex.class}: #{ex.message}\n#{ex.backtrace.take(5).join("\n")}")
      end
    end
  end
end
