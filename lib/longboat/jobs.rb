module Longboat
  class Jobs
    def initialize
      @jobs = []
    end

    def load(collector)
      Dir.entries("./lib/jobs/").each do |file|
        next if file =~ /^\./

        reqname = File.basename(file, ".rb")
        cname = reqname.split('_').map(&:capitalize).join

        require "jobs/#{reqname}"
        @jobs << Kernel.const_get(cname).new(collector)
      end
    end

    def collect!
      @jobs.each do |job|
        job.run
      end
    end

    def collect_every(time = 60, async = true)
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
  end
end
