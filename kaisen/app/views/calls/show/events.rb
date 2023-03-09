# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show
        class Events < View
          option :call_sid, optional: true

          def template
            div(id: "events", class: "w-3/4 overflow-y-scroll h-full") do
            end
          end
        end
      end
    end
  end
end
