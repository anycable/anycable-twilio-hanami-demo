# frozen_string_literal: true

module Kaisen
  class Channel < LiteCable::Channel::Base
    class << self
      def inherited(channel)
        channel.identifier Hanami.app["inflector"].underscore(channel.name)
      end
    end
  end
end
