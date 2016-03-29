require "thread"

module Zabbix
  class MaintenanceSupervisor
    REDIS_NAMESPACE = "maintenance_supervisor"
    REDIS_MONITOR_NAMESPACE = "monitor_supervisor"

    GLOBAL_MUTEX = Mutex.new

    attr_accessor :on_host_maintenance_expired
    attr_accessor :on_monitor_unpaused

    def self.get_or_create(datacenter:, redis:, client:, log:)
      if @supervisors && supervisor = @supervisors[datacenter]
        supervisor
      else
        GLOBAL_MUTEX.synchronize do
          @supervisors ||= {}
          @supervisors[datacenter] = new(datacenter: datacenter, redis: redis, client: client, log: log)
        end
      end
    end

    def initialize(datacenter:, redis:, client:, log:)
      @datacenter = datacenter
      @redis = redis
      @client = client
      @log = log

      @supervising_lock = Mutex.new
    end

    def ensure_supervising
      Thread.new { try_supervise }
      true
    end

    def start_maintenance(host:, until_time:)
      if @client.ensure_host_in_zabbix_maintenance_group(host)
        @redis.hset(redis_expirations_key, host["host"], until_time.to_i)
      end
    end

    def stop_maintenance(host:)
      if @client.ensure_host_not_in_zabbix_maintenance_group(host)
        @redis.hdel(redis_expirations_key, host["host"]) > 0
      end
    end

    def pause_monitor(monitorname:, until_time:)
      @redis.hset(redis_monitor_expirations_key, monitor, until_time.to_i)
    end

    def unpause_monitor(monitorname:)
      @redis.hdel(redis_monitor_expirations_key, monitor) > 0
    end

    def run_expirations(now: Time.now)
      # maintenance expirations
      expired = @redis.hgetall(redis_expirations_key).select { |k, v| v.to_i <= now.to_i }.keys
      expired.select { |hostname|
        begin
          host = @client.get_host(hostname)
          stop_maintenance(host: host)

          @log.info("Brought host out of maintenance: #{hostname}")
          true
        rescue ::Zabbix::Client::HostNotFound
          @redis.hdel(redis_expirations_key, hostname)

          @log.warn("Host not found while removing it from maintenance: #{hostname}")
          false
        rescue => e
          @log.error("Error while removing host from maintenance: #{e}")
          false
        end
      }

      # paused monitor expirations
      expired_monitors = @redis.hgetall(redis_monitor_expirations_key).select { |k, v| v.to_i <= now.to_i }.keys
      expired_monitors.select { |monitor|
        begin
          unpause_monitor(monitor: monitor)

          @log.info("Unpaused monitor: #{hostname}")
          true
        rescue ::Zabbix::Client::MonitorNotFound
          @redis.hdel(redis_monitor_expirations_key, monitor)

          @log.warn("Monitor not found while attempting to unpause: #{monitor}")
          false
        rescue => e
          @log.error("Error unpausing monitor: #{e}")
          false
        end
      }
    end

    private

    def redis_expirations_key
      [REDIS_NAMESPACE, "maintenance_expirations", @datacenter].join(":")
    end

    def redis_monitor_expirations_key
      [REDIS_NAMESPACE, "maintenance_expirations", @datacenter].join(":")
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

    def notify_monitor_unpaused(monitorname)
      on_monitor_unpaused.call(monitorname) if on_monitor_unpaused
    rescue => e
      @log.error("Error notifying monitor unpaused: #{e}")
    end

    def notify_host_maintenance_expired(hostname)
      on_host_maintenance_expired.call(hostname) if on_host_maintenance_expired
    rescue => e
      @log.error("Error notifying host maintenance expired: #{e}")
    end
  end
end
