# frozen_string_literal: true

require "vite_ruby/phlex_helpers"

module Kaisen
  module Views
    module Layouts
      class Base < Phlex::HTML
        include ViteRuby::PhlexHelpers

        def template
          doctype

          html do
            head do
              meta(name: "viewport", content: "width=device-width,initial-scale=1")
              title { "AnyCable Calls" }
              vite_client
              vite_javascript "application", defer: true, type: "module"
              vite_stylesheet "application"
            end

            body do
              main(class: "container mx-auto mt-28 px-5 flex") do
                yield
              end
            end
          end
        end
      end
    end
  end
end

