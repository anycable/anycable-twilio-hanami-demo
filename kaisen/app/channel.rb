# frozen_string_literal: true

module Kaisen
  class Channel < LiteCable::Channel::Base
    private
    def cable_ready = ::Hanami.app["cable_ready"]
    def logger = ::Hanami.app["logger"]
  end
end
