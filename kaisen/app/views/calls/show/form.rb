# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show
        class Form < View
          option :phone, optional: true
          option :call_sid, optional: true
          option :routes, default: -> { Hanami.app["routes"] }

          def template
            form(action: routes.path(:calls), method: :post, class: "sticky bottom-0 flex flex-row p-2 border-gray-400 bg-gray-100 rounded-md mt-4 mr-4") do
              input(type: "text", class: "flex-grow mr-2 px-2", name: "phone", value: phone, disabled: disabled?)
              input(type: "submit", class: "rounded py-2 px-5 bg-red-600 text-white inline-block cursor-pointer hover:bg-red-500 transition-colors disabled:cursor-not-allowed", value: "Call", disabled: disabled?)
            end
          end

          private

          def disabled? = !!call_sid
        end
      end
    end
  end
end
