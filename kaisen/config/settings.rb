# frozen_string_literal: true

module Kaisen
  class Settings < Hanami::Settings
    setting :twilio_phrase, default: "Remember, tomorrow is a new day", constructor: Types::String
    setting :twilio_account_sid, constructor: Types::String.optional
    setting :twilio_auth_token, constructor: Types::String.optional
    setting :twilio_number, constructor: Types::String.optional
    setting :twilio_cable_url, constructor: Types::String.optional
  end
end
