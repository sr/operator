require "metrics"

module SidekiqHelpers
  # Class for logging support in sidekiq
  # Count jobs success and failure
  class Logging
    def call(worker, _job, _queue)
      job_name = job_name(worker)

      begin
        Metrics.increment("sidekiq.jobs.#{job_name}")
        Metrics.increment("sidekiq.jobs")
        yield
        Metrics.increment("sidekiq.jobs.#{job_name}.success")
        Metrics.increment("sidekiq.jobs.success")
      # rubocop:disable RescueException
      rescue Exception => e
        Metrics.increment("sidekiq.jobs.#{job_name}.failure")
        Metrics.increment("sidekiq.jobs.failure")
        raise e
      end
    end

    def job_name(worker)
      worker.class.to_s.underscore
    end
  end
end
