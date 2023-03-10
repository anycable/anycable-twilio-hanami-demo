# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show
        class Events < View
          option :call_sid, optional: true

          def template
            div(class: "w-2/3 overflow-y-scroll h-full") do
              h2(class: "font-bold text-xl mb-5 sticky") { "Active call: #{call_sid}" } if call_sid
              div(id: "events", class: "flex-grow justify-end flex flex-col") do
                stream_from("call_#{call_sid}")
              end
            end
          end
        end
      end
    end
  end
end
