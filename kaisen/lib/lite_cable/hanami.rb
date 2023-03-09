# frozen_string_literal: true

module LiteCable
  module Hanami
    class Registry
      def initialize
        @mapping = {}
      end

      def lookup(channel_id)
        return mapping[channel_id] if mapping.key?(channel_id)

        inflector = ::Hanami.app["inflector"]
        channel_class = inflector.classify(channel_id)
        channels_ns = ::Hanami.app.namespace::Channels

        return unless channels_ns.const_defined?(channel_class)

        channels_ns.const_get(channel_class)
      end

      def add(channel_id, channel_class) = mapping[channel_id] = channel_class

      private

      attr_reader :mapping
    end
  end
end
