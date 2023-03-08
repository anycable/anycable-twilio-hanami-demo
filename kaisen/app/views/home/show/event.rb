# frozen_string_literal: true

module Kaisen
  module Views
    module Home
      class Show
        class Event < View
          option :text
          option :event_type, optional: true

          def template
            div(class: "message rounded text-sm lg:text-base border p-2 mt-2 flex flex-col") do
              plain(text)

              if event_type
                span(class: "self-end text-gray-400 text-xs lg:text-sm truncate mt-1") do
                  plain event_type
                end
              end
            end
          end
        end
      end
    end
  end
end
