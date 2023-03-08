# frozen_string_literal: true

require "vite_ruby"

class ViteRuby
  module PhlexHelpers
    def vite_client
      return unless src = vite_manifest.vite_client_src

      script(src: src, type: "module")
    end

    def vite_javascript(name, **options)
      entries = vite_manifest.resolve_entries(*name, type: :javascript)
      return unless entries

      entries.first.last.each do |src|
        script(src:, **options)
      end
    end

    def vite_asset_path(name, **options)
      vite_manifest.path_for(name, **options)
    end

    def vite_stylesheet(name, **options)
      href = vite_asset_path(name, type: :stylesheet)

      link(rel: "stylesheet", href:, **options)
    end

    def vite_manifest
      ViteRuby.instance.manifest
    end
  end
end
