require "thread"

module ReplicationFixing
  class Monitor
    attr_reader :hostname, :tick

    def initialize(hostname:, tick: 30)
      @hostname = hostname
      @tick = tick

      @on_replication_fixed = []
      @on_status = []
    end

    def on_replication_fixed(&blk)
      @on_replication_fixed << blk
    end

    def on_status(&blk)
      @on_status << blk
    end

    def signal_replication_fixed
      @on_replication_fixed.each(&:call)
    end

    def signal_status(status)
      @on_status.each { |blk| blk.call(status) }
    end
  end

  class MonitorSupervisor
    def initialize(fixing_client:)
      @fixing_client = fixing_client

      @monitors = {}
      @mutex = Mutex.new
    end

    def start_exclusive_monitor(monitor)
      @mutex.synchronize do
        @monitors[monitor.hostname] = monitor
      end

      run_monitor(monitor)
    end

    private
    # Loops every tick seconds waiting for replication to be fixed
    def run_monitor(monitor)
      loop do
        sleep(monitor.tick)

        break unless @monitors.key?(monitor.hostname)
        status = @fixing_client.status(hostname: monitor.hostname)
        monitor.signal_status(status)

        if status.kind_of?(FixingClient::NoErrorDetected)
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
