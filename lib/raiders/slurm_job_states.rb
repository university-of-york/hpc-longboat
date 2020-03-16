class SlurmJobStates
  def initialize(collector, config)
    @collector = collector
    @interval = config[:raid_every]
  end

  def raid
    start_time = (Time.now - @interval).strftime("%H:%M:%S")

    # Get raw data from sacct,
    # read jobs into an array,
    # remove any whitespace from the ends of each string,
    # drop the header,
    # and split each line into state and partition
    raw = `sacct -a -P -o State,Partition -S #{start_time}`.
      lines.
      map(&:strip)[1..-1].
      map{|l|l.split("|")}

    # Make a tally of each state/partition combo
    tally = Hash.new{0}
    raw.each do |job|
      tally[job] += 1
    end

    # Clean up any previously reported metrics
    # to prevent stale labelsets
    @collector.redact!("slurm_job_states")

    # Report new metrics
    tally.each do |labelset, number|
      @collector.report!(
        "slurm_job_states",
        number,
        help: "Number of jobs in each state",
        type: "gauge",
        labels: {state: labelset[0], partition: labelset[1]}
      )
    end
  end
end
