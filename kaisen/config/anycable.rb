# frozen_string_literal: true

require "hanami/prepare"

require "lite_cable/hanami"

LiteCable.channel_registry = LiteCable::Hanami::Registry.new
AnyCable.connection_factory = Kaisen::Connection
