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
            response.body = phlex(Views::Home::Show.new(phone:, call_sid:))
          in Failure(error_code)
            response.redirect_to(routes.path(:root))
          end
        end
      end
    end
  end
end
