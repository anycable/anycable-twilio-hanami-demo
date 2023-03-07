# frozen_string_literal: true

module Kaisen
  module Views
    module Home
      class Show < Phlex::HTML
        include Deps[
          layout: "views.layouts.base"
        ]

        def template
          render layout do
            div(class: "container min-h-screen mx-auto pt-28 pb-28 px-5 flex h-screen") do
              div(class: "min-w-full flex flex-row") do
                nav(id: "calls", class: "border-r border-red-100 mr-4 w-1/3") do
                  h2(class: "font-bold text-2xl mb-5") { "Calls" }
                end
              end
            end
          end
        end
      end
    end
  end
end
