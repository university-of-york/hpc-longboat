module Longboat
  class Jobs
    def initialize(collector, config)
      @collector = collector
      @jobs = []
      @config = config
    end

    def load!
      Dir.entries("./lib/jobs/").each do |file|
        next if file =~ /^\./

        reqname = File.basename(file, ".rb")
        cname = reqname.split('_').map(&:capitalize).join

        require "jobs/#{reqname}"
        @jobs << Kernel.const_get(cname).new(@collector, job_config)
      end
    end

    def collect!
      @jobs.each(&:run)
    end

    def collect_every(time = @config[:collect_every], async = true)
      if async
        Thread.new do
          loop do
            collect!
            sleep(time)
          end
        end
      else
        loop do
          collect!
          sleep(time)
        end
      end
    end

    private

    def job_config
      @config.slice(:collect_every, :metric_prefix)
    end
  end
end
