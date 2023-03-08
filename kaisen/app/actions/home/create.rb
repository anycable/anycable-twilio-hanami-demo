# frozen_string_literal: true

module Kaisen
  module Actions
    module Home
      class Create < Kaisen::Action
        include Deps["operations.make_call"]

        params do
          required(:phone).filled(:string)
        end

        def handle(request, response)
          phone = request.params[:phone]
          result = make_call.call(phone)

          case result
          in Success(call_sid)
            response.body = phlex(action: :show, locals: {phone:, call_sid:}, notice: "Calls has been started!")
          in Failure(error_code, error_msg)
            response.body = phlex(action: :show, locals: {phone:}, alert: error_msg)
          end
        end
      end
    end
  end
end
