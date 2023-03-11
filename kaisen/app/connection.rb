# frozen_string_literal: true

module Kaisen
  class Connection < LiteCable::Connection::Base
    def connect
      sid = request.env["HTTP_X_TWILIO_ACCOUNT"]
      return unless sid

      twilio_account_sid = Hanami.app["settings"].twilio_account_sid
      reject_unauthorized_connection unless sid == twilio_account_sid
    end
  end
end
