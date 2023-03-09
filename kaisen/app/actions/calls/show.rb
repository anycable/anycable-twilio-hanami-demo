# frozen_string_literal: true

module Kaisen
  module Actions
    module Calls
      class Show < Kaisen::Action
        def handle(request, response)
          call_sid = request.params[:id]
          response.body = phlex(locals: {call_sid:})
        end
      end
    end
  end
end
