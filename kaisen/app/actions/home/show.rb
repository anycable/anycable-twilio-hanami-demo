# frozen_string_literal: true

module Kaisen
  module Actions
    module Home
      class Show < Kaisen::Action
        def handle(request, response)
          response.body = phlex(Views::Home::Show.new(call_sid: request.params[:id]))
        end
      end
    end
  end
end
