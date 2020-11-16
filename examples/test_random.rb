class TestRandom
  def initialize(collector, config)
    @collector = collector
    @config = config
  end

  def raid
    # Clean up any previously reported metrics
    # to prevent stale labelsets
    @collector.redact!("die_roll")

    # Report new metrics
    @collector.report!(
      "die_roll",
      rand(4) + 1,
      help: "A random value from 1 to 4 inclusive",
      type: "gauge",
      labels: { die: "d4" }
    )
    @collector.report!(
      "die_roll",
      rand(6) + 1,
      help: "A random value from 1 to 6 inclusive",
      type: "gauge",
      labels: { die: "d6" }
    )
    @collector.report!(
      "die_roll",
      rand(8) + 1,
      help: "A random value from 1 to 8 inclusive",
      type: "gauge",
      labels: { die: "d8" }
    )
    @collector.report!(
      "die_roll",
      rand(10) + 1,
      help: "A random value from 1 to 10 inclusive",
      type: "gauge",
      labels: { die: "d10" }
    )
    @collector.report!(
      "die_roll",
      rand(12) + 1,
      help: "A random value from 1 to 12 inclusive",
      type: "gauge",
      labels: { die: "d12" }
    )
    @collector.report!(
      "die_roll",
      rand(20) + 1,
      help: "A random value from 1 to 20 inclusive",
      type: "gauge",
      labels: { die: "d20" }
    )
    @collector.report!(
      "die_roll",
      rand(100) + 1,
      help: "A random value from 1 to 100 inclusive",
      type: "gauge",
      labels: { die: "d%" }
    )
  end
end
