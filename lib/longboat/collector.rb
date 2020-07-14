module Longboat
  class CollectorTransactionError < Exception; end

  class Collector
    def initialize(config)
      @metrics = {}
      @config = config
      @transaction = nil
    end

    def report!(name, value, help: nil, type: nil, labels: {}, timestamp: Time.now)
      raise CollectorTransactionError if @transaction.nil?

      name = prefix(name)

      @transaction[name] ||= {help: help, type: type}
      @transaction[name][labels] = {value: value, timestamp: timestamp}
    end

    def redact!(name, labels: nil)
      raise CollectorTransactionError if @transaction.nil?

      name = prefix(name)

      if labels.nil?
        @transaction.delete(name)
      else
        @transaction[name].delete(labels)
      end
    end

    def begin!
      @transaction = clone_metrics
    end

    def abort!
      @transaction = nil
    end

    def commit!
      @metrics = @transaction
      @transaction = nil
    end

    def prometheus_metrics
      res = ""
      @metrics.each do |name, metric|
        res << ?\n unless res.empty?
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

    private

    def prefix(name)
      "#{@config[:metric_prefix]}#{name}"
    end
    
    def clone_metrics
      clone = {}

      @metrics.each do |metric, attributes|
        clone[metric] = {}
        clone[metric][:help] = attributes[:help]
        clone[metric][:type] = attributes[:type]

        attributes.each do |labels, value|
          next if [:help, :type].include?(labels)

          clone[metric][labels.clone] = value.clone
        end
      end

      clone
    end
  end
end
