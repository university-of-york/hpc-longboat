require 'sinatra/base'

module Longboat
  module Server
    def self.serve!(collector)
      Sinatra.new {
        get '/metrics' do
          collector.prometheus_metrics
        end
      }.run!
    end
  end
end
