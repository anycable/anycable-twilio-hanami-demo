# frozen_string_literal: true

module Kaisen
  module Views
    module Home
      class Show < View
        option :call_sid, optional: true
        option :phone, optional: true

        def template
          div(class: "min-w-full flex flex-row") do
            div(id: "calls", class: "w-1/4 border-r border-red-100 mr-4") do
              h2(class: "font-bold text-2xl mb-5") { "Calls" }

              render Form.new(phone:)
            end

            render Events.new(call_sid:)
          end
        end
      end
    end
  end
end
