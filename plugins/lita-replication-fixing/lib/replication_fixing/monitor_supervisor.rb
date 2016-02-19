require "thread"

module ReplicationFixing
  class Monitor
    attr_reader :hostname, :tick

    def initialize(hostname:, tick: 30)
      @hostname = hostname
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
    def initialize(fixing_client:)
      @fixing_client = fixing_client

      @monitors = {}
      @mutex = Mutex.new
    end

    def start_exclusive_monitor(monitor)
      success = \
        @mutex.synchronize do
          if @monitors.key?(monitor.hostname)
            false
          else
            @monitors[monitor.hostname] = monitor
            true
          end
        end

      Thread.new { run_monitor(monitor) } if success
      success
    end

    private
    # Loops every tick seconds waiting for replication to be fixed
    def run_monitor(monitor)
      loop do
        sleep(monitor.tick)

        break unless @monitors.key?(monitor.hostname)
        result = @fixing_client.status(hostname: monitor.hostname)
        monitor.signal_tick(result)

        if result.kind_of?(FixingClient::NoErrorDetected)
          monitor.signal_replication_fixed
          break
        end
      end
    ensure
      @mutex.synchronize do
        @monitors.delete(monitor.hostname)
      end
    end
  end
end
