module Longboat
  class Collector
    def initialize
      @metrics = {}
    end

    def report!(name, value, help: nil, type: nil, labels: {}, timestamp: Time.now)
      @metrics[name] ||= {help: help, type: type}
      @metrics[name][labels] = {value: value, timestamp: timestamp}
    end

    def metrics
      res = ""
      @metrics.each do |name, metric|
        res << "#HELP #{name} #{metric[:help]}\n" unless metric[:help].nil?
        res << "#TYPE #{name} #{metric[:type]}\n" unless metric[:type].nil?

        metric.each do |labels, value|
          next if labels == :help
          next if labels == :type
          labellist = []
          labels.each do |k, v|
            labellist << "#{k}=\"#{v}\""
          end
          labellist = labellist.join(",")
          res << "#{name}{#{labellist}} #{value[:value]} #{(value[:timestamp].to_f * 1000).to_i}\n"
        end
      end
      res
    end
  end
end
