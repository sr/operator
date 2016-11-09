module PullAgent
  class Redis
    class Host
      def initialize(host, port, db = nil)
        @redis = ::Redis.new(host: host, port: port, db: db)
      end

      def key?(key)
        @redis.exists(key)
      end

      def hset(key, entry, value)
        @redis.hset(key, entry, value)
      end

      def set(key, value)
        @redis.set(key, value)
      end
    end

    class << self
      def bounce_workers(type, redis_hosts = [])
        valid_types = \
          %w[ PerAccountAutomationWorker
          PerAccountAutomationWorker-timed
          automationRelatedObjectWorkers
          previewWorkers
          PerAccountAutomationWorker ]
        return false if !valid_types.include?(type)

        key = "#{type}-manager-config"
        entry = "restart"
        value = Time.now.to_i
        found = false
        Array(redis_hosts).each do |host_and_port|
          hostname, port_string = host_and_port.split(":")
          port_string ||= "6379" # Default Redis port
          port = Integer(port_string)

          host = Host.new(hostname, port)
          next unless host.key?(key)
          Logger.log(:info, "Found key #{key} on #{hostname}:#{port}. Restarting workers using timestamp value #{value}")
          host.hset(key, entry, value)
          found = true
        end
        found
      end

      def bounce_redis_jobs(hostname, port)
        Logger.log(:info, "Resetting job nodes and monitors for host #{hostname}:#{port}")

        host = Host.new(hostname, port, 10)
        host.set("node_reset", Time.now.to_i)
        host.set("monitor_reset", Time.now.to_i)
      end
    end
  end
end
