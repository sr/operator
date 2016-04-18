require "socket"
require "logger"

module Pardot
  module PullAgent
    class Redis
      class Host
        attr_accessor :host, :port, :db

        def initialize(host, port, db = nil)
          self.host = host
          self.port = port
          self.db   = db
        end

        def has_key?(key)
          output = execute("EXISTS #{key}")
          # http://redis.io/topics/protocol#resp-protocol-description
          if output.start_with?(":1\r\n")
            true
          else
            false
          end
        end

        def hset(key, entry, value)
          execute("HSET #{key} #{entry} #{value}")
        end

        def set(key, value)
          execute("SET #{key} #{value}")
        end

        def execute(cmd)
          TCPSocket.open(@host, @port) do |socket|
            socket.puts("#{"SELECT #{@db}\r\n" if @db}#{cmd}\r\nQUIT\r\n")
            socket.read
          end
        end
      end # Host

      class << self
        def bounce_workers(type, redis_hosts = [])
          valid_types = \
            %w[ automationWorkers
                PerAccountAutomationWorker
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

            host = Redis::Host.new(hostname, port)
            next unless host.key?(key)
            Logger.log(:info, "Found key #{key} on #{hostname}:#{port}. Restarting workers using timestamp value #{value}")
            host.hset(key, entry, value)
            found = true
          end
          found
        end

        def bounce_redis_jobs(hostname, port)
          Logger.log(:info, "Resetting job nodes and monitors for host #{hostname}:#{port}")

          host = Redis::Host.new(hostname, port, 10)
          host.set("node_reset", Time.now.to_i)
          host.set("monitor_reset", Time.now.to_i)
        end
      end # << self
    end
  end
end
