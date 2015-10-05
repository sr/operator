require "console"
require "shell_helper"

class Redis
  class Host
    attr_accessor :host, :port

    def initialize(host, port, db = nil)
      self.host = host
      self.port = port
      self.db   = db
    end

    def has_key?(key)
      cmd = "#{redis_cmd} -h #{self.host} -p #{self.port} #{"-n #{db} " if db}EXISTS #{key}"
      output = ShellHelper.execute_shell(cmd)
      output.to_i == 1
    end

    def hset(key, entry, value)
      cmd = "#{redis_cmd} -h #{self.host} -p #{self.port} #{"-n #{db} " if db}HSET #{key} #{entry} #{value}"
      ShellHelper.execute_shell(cmd)
    end

    def set(key, value)
      cmd = "#{redis_cmd} -h #{self.host} -p #{self.port} #{"-n #{db} " if db}SET #{key} #{value}"
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
            host.hset(key, entry, value)
            return true # found and set
          end
        end
      end

      false
    end

    def redis_installed?
      File.exist?(redis_cmd)
    end

    def redis_cmd
      @_redis_cmd ||= ShellHelper.execute_shell("which redis-cli")
    end

    def bounce_redis_jobs
      yaml = File.open("#{@environment.symfony_path}/config/services/#{@environment.short_name}/nosql/redis/client.yml").readlines.join()
      redis_servers = []
      (1..9).each do |i|
        # We have to regex the yml because symfony 1.0 doesn't use proper yaml format
        # http://rubular.com/r/iRUNxyL35f
        yaml[/redis\.jobs\.servers\.#{i}:\s+d\d:\s+host:\s*['"](.*)['"]/]
        redis_servers << Regexp.last_match(1) if Regexp.last_match
      end
      
      redis_servers.each do |host|
        redis = Redis::Host.new(host, 6379, 10)
        redis.set("node_reset", Time.now.to_i)
        redis.set("monitor_reset", Time.now.to_i)
        Console.log("Reset job nodes and monitors for host #{host}")
      end
    end
  end # << self
end
