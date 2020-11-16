class TestHisto
  def initialize(collector, config)
    @collector = collector
    @config = config
  end

  def raid
    # Clean up any previously reported metrics
    # to prevent stale labelsets
    @collector.redact!("histo")
    @collector.redact!("summ")

    # Report new metrics
    @collector.report!(
      "histo",
      {
        buckets: {
          0.5 => 1,
          1 => 2
        },
        count: 3,
        sum: 3
      },
      help: "A histogram over the data [0.25, 0.75, 2]",
      type: "histogram"
    )
    @collector.report!(
      "summ",
      {
        quantiles: {
          0.5 => 5,
          0.95 => 9.5
        },
        count: 21,
        sum: 105
      },
      help: "A summary of data (0..10).step(0.5)",
      type: "summary"
    )
  end
end
