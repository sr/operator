require "console"
require "shell_helper"

class Redis
  class Host
    attr_accessor :host, :port

    def initialize(host, port)
      self.host = host
      self.port = port
    end

    def has_key?(key)
      cmd = "#{redis_cmd} -h #{self.host} -p #{self.port} EXISTS #{key}"
      output = ShellHelper.execute_shell(cmd)
      output.to_i == 1
    end

    def set_key!(key, entry, value)
      cmd = "#{redis_cmd} -h #{self.host} -p #{self.port} HSET #{key} #{entry} #{value}"
      ShellHelper.execute_shell(cmd)
    end

    def redis_cmd
      Redis.redis_cmd
    end
  end # Host

  class << self
    def bounce_workers(type, redis_hosts=[], redis_ports=[])
      if ! redis_installed?
        Console.log("WARNING: Redis is NOT installed!", :yellow)
        return
      end

      valid_types = \
        %w[ automationWorkers
            PerAccountAutomationWorker
            automationRelatedObjectWorkers
            previewWorkers
            PerAccountAutomationWorker ]
      return if ! valid_types.include?(type)

      # Define stuff
      key = "#{type}-manager-config"
      entry = "restart"
      value = Time.now.to_i

      # Find which port has the key
      redis_ports.each do |port|
        redis_hosts.each do |host_name|
          host = Redis::Host.new(host_name, port)
          if host.has_key?(key)
            Console.log("Found key #{key} on port #{port}, restarting workers using timestamp value #{value}", :yellow)
            host.set_key!(key, entry, value)
            return true # found and set
          end
        end
      end

      false
    end

    def redis_installed?
      File.exists?(redis_cmd)
    end

    def redis_cmd
      @_redis_cmd ||= ShellHelper.execute_shell("which redis-cli")
    end
  end # << self
end
