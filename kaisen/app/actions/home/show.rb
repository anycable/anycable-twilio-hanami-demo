# frozen_string_literal: true

module Kaisen
  module Actions
    module Home
      class Show < Kaisen::Action
        include Deps[
          "views.home.show"
        ]

        def handle(*, response)
          response.body = show.call
        end
      end
    end
  end
end
