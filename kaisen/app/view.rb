# frozen_string_literal: true

module Kaisen
  class View < Phlex::HTML
    register_element :cable_ready_stream_from

    extend Dry::Initializer

    private

    def stream_from(name)
      cable_ready_stream_from(identifier: ::Hanami.app["cable_ready_stream_name"].signed(name))
    end

    def path_for(...) = ::Hanami.app["routes"].path(...)
  end
end
