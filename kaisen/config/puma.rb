# frozen_string_literal: true

max_threads_count = ENV.fetch("HANAMI_MAX_THREADS", 5)
min_threads_count = ENV.fetch("HANAMI_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port        ENV.fetch("HANAMI_PORT", 2300)
environment ENV.fetch("HANAMI_ENV", "development")
workers     ENV.fetch("HANAMI_WEB_CONCURRENCY", 2)

on_worker_boot do
  Hanami.shutdown
end

preload_app!

on_worker_boot(:cable) do |idx, data|
  next if ENV["ANYCABLE_EMBEDDED"] == "false"
  next if idx > 0

  require "anycable/cli"
  require "lite_cable/hanami"

  LiteCable.channel_registry = LiteCable::Hanami::Registry.new
  AnyCable.connection_factory = Kaisen::Connection

  data[:cable] = cable = AnyCable::CLI.new(embedded: true)
  cable.run
end

on_worker_shutdown(:cable) do |idx, data|
  data[:cable]&.shutdown
end
