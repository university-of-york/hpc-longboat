class TestFixed
  def initialize(collector, config)
    @collector = collector
    @config = config
  end

  def raid
    # Clean up any previously reported metrics
    # to prevent stale labelsets
    @collector.redact!("fixed_value")

    # Report new metrics
    @collector.report!(
      "fixed_value",
      4,
      help: "A fixed value",
      type: "gauge"
    )
  end
end
