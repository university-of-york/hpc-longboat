module Longboat
  class Raiders
    def initialize(collector, config)
      @collector = collector
      @raiders = []
      @config = config

      @config[:raiders_path].each do |dir|
        next unless Dir.exist?(dir)

        Dir.entries(dir).each do |file|
          next if file =~ /^\./

          reqname = File.basename(file, ".rb")
          cname = reqname.split('_').map(&:capitalize).join

          require "raiders/#{reqname}"
          @raiders << Kernel.const_get(cname).new(@collector, raider_config)
        end
      end
    end

    def raid!
      @raiders.each(&:raid)
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
