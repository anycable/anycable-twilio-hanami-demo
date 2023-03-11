# frozen_string_literal: true

module Kaisen
  class Settings < Hanami::Settings
    setting :twilio_phrase, default: "Hey, why do you love Ruby?", constructor: Types::String
    # The default value here matches the value from wsdirector fixtures, so you can pass the
    # authentication check.
    setting :twilio_account_sid, default: "AC20230312", constructor: Types::String
    setting :twilio_auth_token, constructor: Types::String.optional
    setting :twilio_number, constructor: Types::String.optional
    setting :twilio_cable_url, constructor: Types::String.optional

    setting :cable_url, default: "ws://localhost:8080/cable", constructor: Types::String
    setting :anycable_broadcast_adapter, default: "nats", constructor: Types::String
    setting :cable_ready_sign_key, default: "s3cЯeT", constructor: Types::String
  end
end
