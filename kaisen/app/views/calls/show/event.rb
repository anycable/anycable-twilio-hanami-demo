# frozen_string_literal: true

module Kaisen
  module Views
    module Calls
      class Show
        class Event < View
          option :text
          option :event_type, optional: true

          def template
            div(class: "rounded text-sm lg:text-base border p-2 mt-2 flex flex-col #{event_class}") do
              plain(text)

              if event_type
                span(class: "self-end text-gray-400 text-xs lg:text-sm truncate mt-1") do
                  plain event_type
                end
              end
            end
          end

          private

          def event_class
            if event_type == "transcript"
              "self-start border-teal-300 mr-4"
            else
              "self-end ml-4"
            end
          end
        end
      end
    end
  end
end
