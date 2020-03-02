class SlurmJobStates
  def initialize(collector)
    @collector = collector
  end

  def run
    start_time = (Time.now - 60).strftime("%H:%M:%S")
    raw = `sacct -a -P -o State -S #{start_time}`.lines.map(&:strip)[1..-1]

    tally = Hash.new{0}

    raw.each do |state|
      tally[state] += 1
    end

    tally.each do |state, number|
      @collector.report!(
        "longboat_slurm_job_states",
        number,
        help: "Number of jobs in each state",
        type: "gauge",
        labels: {state: state}
      )
    end
  end
end
