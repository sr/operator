require "console"
require "socket"

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
      !!(output =~ /\A:1\r\n/)
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
    def bounce_workers(type, redis_hosts=[])

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
      Array(redis_hosts).each do |host_and_port|
        hostname, port_string = host_and_port.split(':')
        port_string ||= "6379" # Default Redis port
        ports = port_string.split('..').map{|d| Integer(d)}
        port_range = ports.length > 1 ? ports[0]..ports[1] : ports
        # Find which port has the key
        port_range.each do |port|
          host = Redis::Host.new(hostname, port)
          if host.has_key?(key)
            Console.syslog("Found key #{key} on port #{port}, restarting workers using timestamp value #{value}")
            host.hset(key, entry, value)
            return true # found and set
          end
        end
      end
      false
    end

    def bounce_redis_jobs(config_file)
      yaml = File.open(config_file).readlines.join()
      redis_servers = []
      (1..9).each do |i|
        # We have to regex the yml because symfony 1.0 doesn't use proper yaml format
        # http://rubular.com/r/4igxCz6E39
        yaml[/redis\.jobs\.servers#{ "\.#{i}" if i > 1 }:\s+d\d:\s+host:\s*['"](.*)['"]/]
        redis_servers << Regexp.last_match(1) if Regexp.last_match
      end
      
      redis_servers.each do |host|
        redis = Redis::Host.new(host, 6379, 10)
        redis.set("node_reset", Time.now.to_i)
        redis.set("monitor_reset", Time.now.to_i)
        Console.syslog("Reset job nodes and monitors for host #{host}")
      end
    end
  end # << self
end
