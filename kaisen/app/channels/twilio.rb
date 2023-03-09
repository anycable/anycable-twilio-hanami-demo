# frozen_string_literal: true

module Kaisen
  module Channels
    class Twilio < Channel
      def subscribed
        puts "[#{call_sid}] Call started"
      end

      def unsubscribed
        puts "[#{call_sid}] Call stopped"
      end

      def handle_message(data)
        puts "[#{call_sid}] Message: #{data["result"]}"
      end

      private

      def call_sid
        params["sid"]
      end
    end
  end
end
