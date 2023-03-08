# frozen_string_literal: true

require "twilio-ruby"

module Kaisen
  module Operations
    class MakeCall
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      include Deps["settings", "logger"]

      def call(phone)
        phrase = settings.twilio_phrase

        @client = Twilio::REST::Client.new(settings.twilio_account_sid, settings.twilio_auth_token)

        twiml = Twilio::TwiML::VoiceResponse.new do |r|
          r.pause(length: 30)
          # r.say(message: phrase)
          r.pause(length: 10)
          # r.say(message: phrase)
          r.pause(length: 10)
          r.hangup
        end.to_s

        from = settings.twilio_number

        call_attrs = {
          to: phone,
          timeout: 30,
          from: from,
          twiml: twiml
        }

        @sid = yield create_call(**call_attrs)

        logger.debug "Calling #{phone} from #{from}... [sid=#{@sid}]"

        yield wait_for_call_to_start

        Success(@sid)
      end

      def create_call(**)
        Success(@client.calls.create(**).sid)
      rescue Twilio::REST::RestError => err
        logger.error "Twilio REST error: #{err.message}"
        Failure([:twilio_rest_error, err.message])
      end

      def wait_for_call_to_start
        wait = 5

        loop do
          wait -= 0.5
          if wait < 0
            return Failure([:call_timed_out, "Call timed out — no answer"])
          end

          sleep 0.5

          response = @client.calls(@sid).fetch

          if response.status == "in-progress"
            logger.debug "Starting streaming..."

            stream = @client.calls(@sid).streams.create(url: settings.twilio_cable_url, track: "both_tracks")

            break
          end
        end

        Success()
      end
    end
  end
end
