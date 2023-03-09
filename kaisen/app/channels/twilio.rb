# frozen_string_literal: true

module Kaisen
  module Channels
    class Twilio < Channel
      def subscribed
        logger.info "[#{call_sid}] Call started"

        cable_ready.append(
          selector: "#events",
          html: Views::Home::Show::Event.new(text: "Call started: #{call_sid}", event_type: "start").call
        ).broadcast_to("calls")
      end

      def unsubscribed
        logger.info "[#{call_sid}] Call stopped"

        cable_ready.append(
          selector: "#events",
          html: Views::Home::Show::Event.new(text: "Call stopped: #{call_sid}", event_type: "end").call
        ).broadcast_to("calls")
      end

      def handle_message(data)
        logger.info "[#{call_sid}] Message: #{data["result"]}"

        result = data["result"]

        cable_ready.append(
          selector: "#events",
          html: Views::Home::Show::Event.new(text: result.fetch("text"), event_type: result.fetch("event")).call
        ).broadcast_to("calls")
      end

      private

      def call_sid
        params["sid"]
      end
    end
  end
end
