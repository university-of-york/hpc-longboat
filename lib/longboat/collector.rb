module Longboat
  class Collector
    def initialize
      @metrics = {}
    end

    def report!(name, value, help: nil, type: nil, labels: {})
      @metrics[name] ||= {help: help, type: type}
      @metrics[name][labels] = value
    end

    def metrics
      timestamp = (Time.now.to_f * 1000).to_i
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
          res << "#{name}{#{labellist}} #{value} #{timestamp}\n"
        end
      end
      res
    end
  end
end
