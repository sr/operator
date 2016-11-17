require "thread"

module Zabbix
  class ChefProblemReportCoordinator
    REDIS_NAMESPACE = "chef_problem_report_coordinator".freeze

    def initialize(datacenter:, redis:, interval_seconds:)
      @datacenter = datacenter
      @redis = redis
      @interval_seconds = interval_seconds
    end

    # perform_exclusive yields to the given block if it's time to report on chef
    # problems for this datacenter. It is necessary because more than one
    # HAL9000 process is running, but only one should report per interval.
    # Otherwise, 2x or 3x announcements would be made.
    def perform_exclusive
      redis_eval = @redis.eval(%(
        if redis.call('exists', KEYS[1]) == 0 then
          return redis.call('setex', KEYS[1], #{@interval_seconds}, '')
        else
          return nil
        end
      ), keys: [last_report_key])

      if redis_eval
        begin
          yield
        rescue
          @redis.del(last_report_key)
          raise
        end
      end
    end

    private

    def last_report_key
      [REDIS_NAMESPACE, @datacenter, "last_report"].join(":")
    end
  end
end
