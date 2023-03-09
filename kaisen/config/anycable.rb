# frozen_string_literal: true

require "hanami/prepare" unless Hanami.app.prepared?

require "lite_cable/hanami"

LiteCable.channel_registry = LiteCable::Hanami::Registry.new.tap do
  _1.add("CableReady::Stream", Kaisen::CableReady::Hanami::StreamChannel)
end

AnyCable.connection_factory = Kaisen::Connection
