# frozen_string_literal: true

require "vite_ruby/phlex_helpers"

module Kaisen
  module Views
    module Layouts
      class Base < View
        include ViteRuby::PhlexHelpers

        param :content
        option :alert, optional: true
        option :notice, optional: true

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
              flash
              main(class: "container min-h-screen mx-auto pt-28 pb-28 px-5 flex h-screen") do
                render content
              end
            end
          end
        end

        private

        def flash
          div(class:"absolute mt-1 w-full") do
            div(class: "flex justify-center") do
              if alert
                div(class: "max-w-sm bg-white border-t-4 border-red-500 rounded-b text-red-900 px-4 py-3 shadow-md", role: "alert", data: {controller: "alert"}) do
                  p(class: "text-sm") { alert }
                end
              end

              if notice
                div(class: "max-w-sm bg-white border-t-4 border-teal-500 rounded-b text-teal-900 px-4 py-3 shadow-md", role: "alert", data: {controller: "alert"}) do
                  p(class: "text-sm") { notice }
                end
              end
            end
          end
        end
      end
    end
  end
end

