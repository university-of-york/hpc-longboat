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

        case metric[:type]
        when "gauge", "counter"
          metric.each do |labelset, value|
            next if labelset == :help
            next if labelset == :type
            res << stringify_gaugecounter(name, labelset, value[:value], value[:timestamp])
          end
        when "histogram"
          metric.each do |labelset, value|
            next if labelset == :help
            next if labelset == :type
            res << stringify_histogram(name, labelset, value[:value], value[:timestamp])
          end
        when "summary"
          metric.each do |labelset, value|
            next if labelset == :help
            next if labelset == :type
            res << stringify_summary(name, labelset, value[:value], value[:timestamp])
          end
        end
      end

      res
    end

    private

    def stringify_gaugecounter(name, labelset, value, timestamp)
      labels = prometheus_labels(labelset)
      timestamp = (timestamp.to_f * 1000).to_i

      "#{name}{#{labels}} #{value} #{timestamp}\n"
    end

    def stringify_histogram(name, labelset, data, timestamp)
      res = ""

      data[:buckets].each do |bkt, cnt|
        res << stringify_gaugecounter("#{name}_bucket", labelset.merge({le: bkt.to_s}), cnt, timestamp)
      end

      res << stringify_gaugecounter("#{name}_bucket", labelset.merge({le: "+Inf"}), data[:count], timestamp)
      res << stringify_gaugecounter("#{name}_count", labelset, data[:count], timestamp)
      res << stringify_gaugecounter("#{name}_sum", labelset, data[:sum], timestamp)
      
      res
    end

    def stringify_summary(name, labelset, data, timestamp)
      res = ""

      data[:quantiles].each do |qtl, val|
        res << stringify_gaugecounter(name, labelset.merge({quantile: qtl.to_s}), val, timestamp)
      end

      res << stringify_gaugecounter("#{name}_count", labelset, data[:count], timestamp)
      res << stringify_gaugecounter("#{name}_sum", labelset, data[:sum], timestamp)
      
      res
    end

    def prometheus_labels(labelset)
      labellist = []

      labelset.each do |k, v|
        labellist << "#{k}=\"#{v}\""
      end

      labellist.join(",")
    end

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
