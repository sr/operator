require "thread"

module Zabbix
  class MonitorSupervisor
    REDIS_NAMESPACE = "monitor_supervisor"

    def initialize(datacenter:, redis:, client:, log:)
      @datacenter = datacenter
      @redis = redis
      @client = client
      @log = log
    end

    def ensure_supervising
      Thread.new { try_supervise }
      true
    end

    def pause_monitor(monitorname:, until_time:)
      @redis.hset(redis_expirations_key, monitor, until_time.to_i)
    end

    def unpause_monitor(monitorname:)
      @redis.hdel(redis_expirations_key, monitor) > 0
    end

    def run_expirations(now: Time.now)
      expired = @redis.hgetall(redis_expirations_key).select { |k, v| v.to_i <= now.to_i }.keys
      expired.select { |monitorname|
        begin
          unpause_monitor(monitorname)

          @log.info("Unpaused monitor: #{monitorname}")
          true
        rescue ::Zabbix::Client::MonitorNotFound
          @redis.hdel(redis_expirations_key, monitorname)

          @log.warn("Monitor not found while unpausing it: #{monitorname}")
          false
        rescue => e
          @log.error("Error while unpausing monitor: #{e}")
          false
        end
      }
    end

    private

    def redis_expirations_key
      [REDIS_NAMESPACE, "monitor_pause_expiry", @datacenter].join(":")
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

            expirations.each { |hostname| notify_host_maintenance_expired(hostname) }
            sleep 60
          end
        ensure
          @supervising_lock.unlock
        end
      else
        @log.debug("Supervisor already executing")
      end
    end

    def notify_host_maintenance_expired(monitor)
      on_host_maintenance_expired.call(hostname) if on_host_maintenance_expired
    rescue => e
      @log.error("Error notifying host maintenance expired: #{e}")
    end
  end
end
