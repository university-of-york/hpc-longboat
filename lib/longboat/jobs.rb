module Longboat
  module Jobs
    class << self
      def collect!
        start_time = (Time.now - 15 * 60).strftime("%H:%M:%S")
        raw = `sacct -a -P -o State -S #{start_time}`.lines.map(&:strip)[1..-1]

        tally = Hash.new{0}

        raw.each do |state|
          tally[state] += 1
        end

        tally.each do |state, number|
          Longboat::Metrics.report!(
            "longboat_slurm_job_state",
            number,
            help: "Number of jobs in each state",
            type: "gauge",
            labels: {state: state}
          )
        end
      end
    end

    Longboat::Metrics.register!(self)
  end
end
