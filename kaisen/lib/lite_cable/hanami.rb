# frozen_string_literal: true

module LiteCable
  module Hanami
    class Registry
      def lookup(channel_id)
        inflector = ::Hanami.app["inflector"]
        channel_class = inflector.classify(channel_id)
        channels_ns = ::Hanami.app.namespace::Channels

        return unless channels_ns.const_defined?(channel_class)

        channels_ns.const_get(channel_class)
      end
    end
  end
end
