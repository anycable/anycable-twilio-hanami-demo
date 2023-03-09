# frozen_string_literal: true

require "bundler/inline"

begin
  retried = false
  gemfile(retried, quiet: true) do
    source "https://rubygems.org"

    gem "grpc_kit", "~> 0.5.1"
    gem "ffaker"
    gem "debug", "~> 1.7.0"
  end
rescue
  retried = true
  retry
end

require "socket"

require_relative "vosk_grpc/stt_service_services_pb"

class RecognitionStream
  # The number of seconds to wait before sending a final response
  RESPOND_THRESHOLD = 4

  attr_reader :stream, :incoming, :thread

  def initialize(stream)
    @stream = stream
    @incoming = Queue.new

    # Consume all requests asynchronously
    @thread = Thread.new do
      stream.each { @incoming << _1 }
    end
  end

  def process
    # first, fetch the config
    config_payload = incoming.pop(timeout: 2)

    unless config_payload&.config
      raise "No config sent in 2s"
    end

    config = config_payload.config

    partial = config.specification.partial_results

    ::GrpcKit.logger.info "Received streaming recognize configuration: #{config.specification}"

    last_msg = Time.now
    tick = 0
    words = FFaker::CheesyLingo.sentence.split(/,?\s+/)

    loop do
      msg = incoming.pop(timeout: 1)

      # nothing was sent
      if msg.nil?
        ::GrpcKit.logger.info "No new data was received in 1s. Finalizing..."
        sleep RESPOND_THRESHOLD
        stream.send_msg build_response(final: true, text: "")
        break
      end

      ts = Time.now

      if ts - last_msg > RESPOND_THRESHOLD
        text = words.join(" ")

        ::GrpcKit.logger.info "Sending final recognition result: #{text}"
        stream.send_msg build_response(final: true, text:)

        last_msg = ts
        tick = 0
        words = FFaker::CheesyLingo.sentence.split(/,?\s+/)
      elsif partial
        tick += 1
        part = words.take(tick)

        # replace the last word with a random word
        part[part.size - 1] = FFaker::BaconIpsum.word

        text = part.join(" ")

        ::GrpcKit.logger.info "Sending partial recognition result: #{text}"
        stream.send_msg build_response(final: false, text:)
      end
    end
  ensure
    thread.kill
  end

  def build_response(final: false, text:)
    ::Vosk::Stt::V1::StreamingRecognitionResponse.new(
      chunks: [
        ::Vosk::Stt::V1::SpeechRecognitionChunk.new(
          alternatives: [
            ::Vosk::Stt::V1::SpeechRecognitionAlternative.new(
              text:,
              confidence: 1
            )
          ],
          final:
        )
      ]
    )
  end
end

class VoskService < Vosk::Stt::V1::SttService::Service
  def streaming_recognize(stream)
    RecognitionStream.new(stream).process
  end
end

GrpcKit.logger = Logger.new(STDOUT)
GrpcKit.loglevel = :info

sock = TCPServer.new(5001)
server = GrpcKit::Server.new
server.handle(VoskService.new)


GrpcKit.logger.info "Starting Ffaker Vosk gRPC on localhost:5001"

loop do
  conn = sock.accept
  server.run(conn)
end
