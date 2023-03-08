# frozen_string_literal: true

require "bundler/inline"

gemfile(true, quiet: true) do
  source "https://rubygems.org"

  gem "twilio-ruby", "~> 5.74.0"
  gem "dotenv"
  gem "debug", "~> 1.7.0"
end

require "dotenv"
Dotenv.load(File.join(__dir__, ".env"))

require "twilio-ruby"

phrase = ENV["PHRASE"] || "Remember, tomorrow is a new day"

client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])

twiml = Twilio::TwiML::VoiceResponse.new do |r|
  r.pause(length: 5)
  r.say(message: phrase)
  r.pause(length: 10)
  r.say(message: phrase)
  r.pause(length: 10)
  r.hangup
end.to_s

to = ENV.fetch("TO") { raise "Please, provide to number via the TO env var" }
from = ENV["TWILIO_NUMBER"]

call_attrs = {
  to: to,
  timeout: 30,
  from: from,
  twiml: twiml
}

sid = client.calls.create(**call_attrs).sid

$stdout.puts "Calling #{to} from #{from}..."

$stdout.puts "Expect to here:\n\n #{phrase}"

wait = 5

loop do
  wait -= 0.5
  if wait < 0
    $stdout.puts "Timed out to wait for the call to start"
    break
  end

  sleep 0.5
  call = client.calls(sid).fetch

  if call.status == "in-progress"
    $stdout.puts "Starting streaming..."

    client.calls(sid).streams.create(url: ENV["TWILIO_CABLE_URL"], track: "both_tracks")
    break
  end
end
