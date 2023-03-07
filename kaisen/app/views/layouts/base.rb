# frozen_string_literal: true

module Kaisen
  module Views
    module Layouts
      class Base < Phlex::HTML
        include ViteHanami::TagHelpers

        def template
          doctype

          html do
            head do
              meta(name: "viewport", content: "width=device-width,initial-scale=1")
              title { "AnyCable Calls" }
              vite_client
              vite_javascript "application"
            end

            body do
              main(class: "container mx-auto mt-28 px-5 flex") do
                yield
              end
            end
          end
        end

        private

        def vite_client
          return unless src = vite_manifest.vite_client_src

          script(src: src, type: "module")
        end

        def vite_javascript(name, **options)
          entries = vite_manifest.resolve_entries(*name, type: :javascript)
          return unless entries

          src = entries.first.last.first

          script(src:, defer: true)
        end

        def vite_asset_path(name, **options)
          vite_manifest.path_for(name, **options)
        end

        def vite_stylesheet(name, **options)
          href = vite_asset_path(name, type: :stylesheet)

          link(rel: "stylesheet", href:, **options)
        end

        def vite_modulepreload(*sources, crossorigin:)
          _safe_tags(*sources) { |source|
            href = asset_path(source)
            _push_promise(href, as: :script)
            html.link(rel: 'modulepreload', href: href, as: :script, crossorigin: crossorigin)
          }
        end
      end
    end
  end
end

