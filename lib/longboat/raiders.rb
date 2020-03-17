module Longboat
  class Raiders
    def initialize(collector, config)
      @collector = collector
      @raiders = {}
      @config = config

      @config[:raiders_path].each do |dir|
        next unless Dir.exist?(dir)

        Dir.entries(dir).each do |file|
          next unless file =~ /\A(?!:[^.]).*[^_].*\.rb\Z/

          reqname = File.basename(file, ".rb")
          cname = reqname.split('_').map(&:capitalize).join

          require "#{dir}/#{reqname}"
          @raiders[reqname] = Kernel.const_get(cname).new(@collector, raider_config)
        end
      end
    end

    def raid!
      @raiders.each do |name, raider|
        start_time = Time.now
        raider.raid
        end_time = Time.now
        time_taken = end_time - start_time

        @collector.report!(
          "longboat_meta_raider_runtime",
          (time_taken.to_f * 1000).to_i,
          help: "Time taken by a raider whilst raiding in ms",
          type: "guage",
          labels: {raider: name}
        )
      end
    end

    def raid_every(time = @config[:raid_every], async = true)
      if async
        Thread.new do
          loop do
            raid!
            sleep(time)
          end
        end
      else
        loop do
          raid!
          sleep(time)
        end
      end
    end

    private

    def raider_config
      @config.slice(:raid_every, :metric_prefix)
    end
  end
end
