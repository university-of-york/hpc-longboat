require 'yaml'

class TestConfig
  def initialize(collector, config)
    @collector = collector
    @config = config
    @config.merge!(Longboat::Config.for_raider do
      opt :test_config, "Config file for test_config", type: String
    end)

    @name = "configurable_value"
    @config_file = {}
    @config_file = YAML.load_file(@config[:test_config]) if @config[:test_config]
  end

  def raid
    # Clean up any previously reported metrics
    # to prevent stale labelsets
    @collector.redact!(@name)

    # Report new metrics
    value = @config_file["configurable_value"] || 4
    @collector.report!(
      @name,
      value,
      help: "A value specified on the command line at runtime",
      type: "gauge",
      labels: {
        given: @config[:test_config_given] ? 1 : 0
      }
    )
  end
end
