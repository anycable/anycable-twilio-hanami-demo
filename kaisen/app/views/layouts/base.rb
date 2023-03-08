# frozen_string_literal: true

require "vite_ruby/phlex_helpers"

module Kaisen
  module Views
    module Layouts
      class Base < View
        include ViteRuby::PhlexHelpers

        param :content

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
              main(class: "container min-h-screen mx-auto pt-28 pb-28 px-5 flex h-screen") do
                render content
              end
            end
          end
        end
      end
    end
  end
end

