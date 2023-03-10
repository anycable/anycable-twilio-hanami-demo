# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show < View
        option :call_sid, optional: true
        option :phone, optional: true

        def template
          div(class: "min-w-full flex flex-row") do
            div(class: "w-1/3 border-r border-red-100 mr-4") do
              a(href: path_for(:calls)) { h2(class: "font-bold text-2xl mb-5") { "Calls" } }

              render Form.new(phone:)

              hr(class: "border-red-100 mt-2")

              div(id: "calls", class: "pr-2") do
                stream_from("calls")
              end
            end

            render Events.new(call_sid:)
          end
        end
      end
    end
  end
end
