# frozen_string_literal: true

module Kaisen
  module Channels
    class Twilio < Channel
      def subscribed
        logger.info "[#{call_sid}] Call started"

        cable_ready.append(
          selector: "#calls",
          html: render_call(call_sid:)
        ).broadcast_to("calls")

        cable_ready.append(
          selector: "#events",
          html: render_event(text: "Call started", event_type: "start")
        ).broadcast_to("call_#{call_sid}")
      end

      def unsubscribed
        logger.info "[#{call_sid}] Call stopped"

        cable_ready.remove(
          selector: "#call_#{call_sid}"
        ).broadcast_to("calls")

        cable_ready.append(
          selector: "#events",
          html: render_event(text: "Call stopped", event_type: "end")
        ).broadcast_to("call_#{call_sid}")
      end

      def handle_message(data)
        logger.info "[#{call_sid}] Message: #{data["result"]}"

        result = data["result"]

        # Do not show errors in the browser
        return if result["event"] == "error"

        cable_ready.append(
          selector: "#events",
          html: render_event(text: result.fetch("text"), event_type: result.fetch("event"))
        ).broadcast_to("call_#{call_sid}")
      end

      private

      def call_sid
        params["sid"]
      end

      def render_event(**)
        Views::Calls::Show::Event.new(**).call
      end

      def render_call(**)
        Views::Calls::Show::Call.new(**).call
      end
    end
  end
end
