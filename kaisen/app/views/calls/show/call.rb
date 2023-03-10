# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show
        class Call < View
          option :call_sid

          def template
            div(id: "call_#{call_sid}", class: "m2 truncate") do
              a(href: path_for(:call, id: call_sid)) do
                "Call #{call_sid}"
              end
            end
          end
        end
      end
    end
  end
end
