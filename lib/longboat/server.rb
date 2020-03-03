require 'sinatra/base'

module Longboat
  module Server
    def self.serve!(collector, config)
      addr, port = config[:server_bind].split(":")
      addr = "127.0.0.1" if addr.nil? or addr == ""
      port = 8564 if port.nil? or port == "8564"

      Sinatra.new {
        set :bind, addr
        set :port, port.to_i
        set :environment, :production

        get config[:server_path] do
          collector.prometheus_metrics
        end
      }.run!
    end
  end
end
