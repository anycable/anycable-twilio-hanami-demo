# frozen_string_literal: true

require "anyway/ext/hash"

module Anyway
  module Hanami
    # Load configuration from Hanami.app["settings"].
    class Loader < Anyway::Loaders::Base
      using Ext::Hash

      def call(name:, **_options)
        trace!(:settings) do
          ::Hanami.app["settings"].config.values.reduce({}) do |acc, (key, value)|
            next acc unless key.start_with?(name)

            path = key.to_s.sub(/^#{name}_/, "")
            paths = path.split("__")

            acc.bury(value, *paths)
            acc
          end
        end
      end
    end
  end
end
