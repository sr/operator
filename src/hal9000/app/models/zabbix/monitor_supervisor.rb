require "thread"

module Zabbix
  class MonitorSupervisor
    REDIS_NAMESPACE = "monitor_supervisor".freeze

    GLOBAL_MUTEX = Mutex.new

    attr_accessor :on_monitor_unpaused

    def self.get_or_create(datacenter:, redis:, client:, log:)
      if @supervisors && supervisor = @supervisors[datacenter]
        supervisor
      else
        GLOBAL_MUTEX.synchronize do
          @supervisors ||= {}
          @supervisors[datacenter] = new(datacenter: datacenter, redis: redis, log: log)
        end
      end
    end

    def initialize(datacenter:, redis:, log:)
      @datacenter = datacenter
      @redis = redis
      @log = log

      @supervising_lock = Mutex.new
    end

    def ensure_supervising
      Thread.new do
        try_supervise
      end
      true
    end

    def pause_monitor(monitorname:, until_time:)
      @redis.hset(redis_expirations_key, monitorname, until_time.to_i)
    end

    def unpause_monitor(monitorname:)
      @redis.hdel(redis_expirations_key, monitorname) > 0
    end

    def run_expirations(now: Time.now)
      expired_monitors = @redis.hgetall(redis_expirations_key).select { |_k, v| v.to_i <= now.to_i }.keys
      expired_monitors.select do |monitorname|
        begin
          unpause_monitor(monitorname: monitorname)

          @log.info("Unpaused monitor: #{monitorname}")
          true
        rescue ::Lita::Handlers::Zabbix::MonitorNotFound
          @redis.hdel(redis_expirations_key, monitorname)

          @log.warn("Monitor not found while attempting to unpause: #{monitorname}")
          false
        rescue => e
          @log.error("Error unpausing monitor #{monitorname}: #{e}")
          false
        end
      end
    end

    def get_paused_monitors(now: Time.now)
      @redis.hgetall(redis_expirations_key).select { |_k, v| v.to_i > now.to_i }.keys
    end

    private

    def redis_expirations_key
      [REDIS_NAMESPACE, "monitor_pause_expirations", @datacenter].join(":")
    end

    def try_supervise
      if @supervising_lock.try_lock
        begin
          loop do
            expirations = \
              begin
                run_expirations
              rescue => e
                @log.error("Error while running expirations: #{e}")
                []
              end

            expirations.each do |monitorname|
              notify_monitor_unpaused(monitorname)
            end
            sleep 60
          end
        ensure
          @supervising_lock.unlock
        end
      else
        @log.debug("Supervisor already executing")
      end
    end

    def notify_monitor_unpaused(monitorname)
      on_monitor_unpaused.call(monitorname) if on_monitor_unpaused
    rescue => e
      @log.error("Error notifying monitor unpaused: #{e}")
    end
  end
end
