# frozen_string_literal: true

module Kaisen
  module Channels
    class Twilio < Channel
      def subscribed
        logger.info "[#{call_sid}] Call started"

        cable_ready.append(
          selector: "#events",
          html: render_event(text: "Call started: #{call_sid}", event_type: "start")
        ).broadcast_to("calls")
      end

      def unsubscribed
        logger.info "[#{call_sid}] Call stopped"

        cable_ready.append(
          selector: "#events",
          html: render_event(text: "Call stopped: #{call_sid}", event_type: "end")
        ).broadcast_to("calls")
      end

      def handle_message(data)
        logger.info "[#{call_sid}] Message: #{data["result"]}"

        result = data["result"]

        cable_ready.append(
          selector: "#events",
          html: render_event(text: result.fetch("text"), event_type: result.fetch("event"))
        ).broadcast_to("calls")
      end

      private

      def call_sid
        params["sid"]
      end

      def render_event(**)
        Views::Calls::Show::Event.new(**).call
      end
    end
  end
end
