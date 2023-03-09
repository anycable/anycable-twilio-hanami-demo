# frozen_string_literal: true

module Kaisen
  class Settings < Hanami::Settings
    setting :twilio_phrase, default: "Remember, tomorrow is a new day", constructor: Types::String
    setting :twilio_account_sid, constructor: Types::String.optional
    setting :twilio_auth_token, constructor: Types::String.optional
    setting :twilio_number, constructor: Types::String.optional
    setting :twilio_cable_url, constructor: Types::String.optional

    setting :cable_url, default: "ws://localhost:8080/cable", constructor: Types::String
    setting :anycable_broadcast_adapter, default: "nats", constructor: Types::String
    setting :cable_ready_sign_key, default: "s3cЯeT", constructor: Types::String
  end
end
