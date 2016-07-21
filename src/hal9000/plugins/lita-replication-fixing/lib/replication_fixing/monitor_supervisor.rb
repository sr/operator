require "thread"

module ReplicationFixing
  class Monitor
    attr_reader :shard, :tick

    def initialize(shard:, tick: 30)
      @shard = shard
      @tick = tick

      @on_replication_fixed = []
      @on_tick = []
    end

    def on_replication_fixed(&blk)
      @on_replication_fixed << blk
    end

    def on_tick(&blk)
      @on_tick << blk
    end

    def signal_replication_fixed
      @on_replication_fixed.each(&:call)
    end

    def signal_tick(result)
      @on_tick.each { |blk| blk.call(result) }
    end
  end

  class MonitorSupervisor
    MONITOR_NAMESPACE = "monitor_supervisor".freeze

    def initialize(redis:, fixing_client:)
      @redis = redis
      @fixing_client = fixing_client
    end

    def start_exclusive_monitor(monitor)
      key = build_key(monitor)
      redis_eval = @redis.eval(%(
        if redis.call('exists', KEYS[1]) == 0 then
          return redis.call('setex', KEYS[1], #{monitor.tick.ceil}, '')
        else
          return nil
        end
      ), keys: [key])
      success = redis_eval ? true : false

      Thread.new { run_monitor(monitor) } if success
      success
    end

    private

    # Loops every tick seconds waiting for replication to be fixed
    def run_monitor(monitor)
      key = build_key(monitor)

      loop do
        next_run = Process.clock_gettime(Process::CLOCK_MONOTONIC) + monitor.tick
        until Process.clock_gettime(Process::CLOCK_MONOTONIC) >= next_run
          @redis.expire(key, monitor.tick.ceil)
          sleep([1, monitor.tick].min)
        end

        result = @fixing_client.status(shard_or_hostname: monitor.shard)
        monitor.signal_tick(result)

        if result.is_a?(FixingClient::NoErrorDetected)
          monitor.signal_replication_fixed
          break
        end
      end
    ensure
      @redis.del(key)
    end

    private

    def build_key(monitor)
      [MONITOR_NAMESPACE, monitor.shard.to_s].join(":")
    end
  end
end
