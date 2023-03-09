# frozen_string_literal: true

Hanami.app.register_provider(:cable_ready) do
  prepare do
    require "cable_ready/hanami"
  end

  start do
    broadcaster = Kaisen::CableReady::Hanami::Broadcaster.new
    stream_name = Kaisen::CableReady::Hanami::StreamName.new

    register "cable_ready", broadcaster
    register "cable_ready_stream_name", stream_name
  end
end
