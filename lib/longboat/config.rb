require 'optimist'

module Longboat
  module Config
    def self.parse!
      parser = Optimist::Parser.new do
        # Collection interval
        opt :raid_every,     "Collection interval",               type: Integer,    default: 60

        # Job data
        opt :raiders_path,   "Paths to search for raiders",       type: String,     default: "./lib/raiders",     multi: true
        opt :metric_prefix,  "Prefix for metric names",           type: String,     default: "longboat_"

        # Sinatra server
        opt :server_bind,    "Server listening address",          type: String,     default: "127.0.0.1:8564"
        opt :server_path,    "Path to metrics",                   type: String,     default: "/metrics"

        # Testing
        opt :test,           "Output metrics to stdout and quit", type: TrueClass,  default: false
      end
      parser.ignore_invalid_options = true

      begin
        parser.parse
      rescue Optimist::HelpNeeded
        parser.educate
        exit
      rescue Optimist::VersionNeeded
        exit
      end
    end

    def self.for_raider(&block)
      parser = Optimist::Parser.new(&block)
      parser.ignore_invalid_options = true
      parser.parse
    end
  end
end
