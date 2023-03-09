# frozen_string_literal: true

require "base64"
require "json"

module Kaisen
  module CableReady
    module Hanami
      class StreamName
        def signed(name)
          data = ::Base64.strict_encode64(name.to_json)
          digest = generate_digest(data)
          "#{data}--#{generate_digest(data)}"
        end

        private

        def generate_digest(data)
          require "openssl" unless defined?(OpenSSL)
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, ::Hanami.app["settings"][:cable_ready_sign_key], data)
        end
      end

      class Broadcaster
        # https://github.com/stimulusreflex/cable_ready/blob/e11b123255159566c79ce5b7fad9724d9b67e438/lib/cable_ready/config.rb#L53
        OPERATIONS =
          Set.new(%i[
            add_css_class
            append
            clear_storage
            console_log
            console_table
            dispatch_event
            go
            graft
            inner_html
            insert_adjacent_html
            insert_adjacent_text
            morph
            notification
            outer_html
            prepend
            push_state
            redirect_to
            reload
            remove
            remove_attribute
            remove_css_class
            remove_storage_item
            replace
            replace_state
            scroll_into_view
            set_attribute
            set_cookie
            set_dataset_property
            set_focus
            set_meta
            set_property
            set_storage_item
            set_style
            set_styles
            set_title
            set_value
            text_content
          ]).freeze

        def initialize
          @operations = []
        end

        def broadcast_to(name)
          clients_received = LiteCable.broadcast name, {
            "cableReady" => true,
            "operations" => operations_payload,
            "version" => "5.0.0"
          }
          reset!
        end

        def respond_to_missing?(name, ...) = OPERATIONS.include?(name)

        def method_missing(name, *args, **kwargs, &block)
          if OPERATIONS.include?(name)
            operations << {operation: name, **kwargs}
            self
          else
            super
          end
        end

        private

        attr_reader :operations

        def operations_payload
          operations
        end

        def reset!
          operations.clear
        end
      end
    end
  end
end
