# frozen_string_literal: true

require "hanami"
require "phlex"
require "vite_hanami"

module Kaisen
  class App < Hanami::App
    environment :development do
      config.middleware.use(ViteRuby::DevServerProxy) if ViteRuby.run_proxy?

      # Allow @vite/client to hot reload changes in development
      config.actions.content_security_policy[:script_src] += "'unsafe-eval' 'unsafe-inline'"
      config.actions.content_security_policy[:connect_src] = "ws://#{ ViteRuby.config.host_with_port }"
      config.actions.content_security_policy[:style_src] = "'unsafe-eval'"
    end
  end
end
