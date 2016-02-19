require "spec_helper"
require "thread"
require "replication_fixing/hostname"
require "replication_fixing/monitor_supervisor"

module ReplicationFixing
  RSpec.describe MonitorSupervisor do
    include Lita::RSpec

    let(:ignore_client) { IgnoreClient.new(Lita.redis) }
    let(:fixing_status_client) { FixingStatusClient.new(Lita.redis) }
    let(:logger) { Logger.new("/dev/null") }

    let(:fixing_client) {
      FixingClient.new(
        repfix_url: "https://repfix.example",
        ignore_client: ignore_client,
        fixing_status_client: fixing_status_client,
        log: logger,
      )
    }

    subject(:supervisor) { MonitorSupervisor.new(fixing_client: fixing_client) }

    describe "#start_exclusive_monitor" do
      it "monitors the host every <tick> seconds, until it is fixed" do
        # 1) Fixable error
        # 2) Fix active
        # 3) No longer erroring
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/1/dallas")
          .and_return(
            {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
            {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
            {body: JSON.dump("is_erroring" => false)},
          )

        mutex = Mutex.new
        var = ConditionVariable.new

        hostname = Hostname.new("db-d1")
        monitor = Monitor.new(hostname: hostname, tick: 0.001)

        results = []
        monitor.on_tick do |result|
          results << result
        end

        fixed = false
        monitor.on_replication_fixed do
          mutex.synchronize do
            fixed = true
            var.signal
          end
        end

        expect(supervisor.start_exclusive_monitor(monitor)).to be_truthy
        mutex.synchronize do
          var.wait(mutex, 0.2)
          fail "Monitor never signaled the fix was completed" unless fixed

          expect(results.length).to eq(3)
        end
      end

      it "doesn't start a new monitor if one already exists" do
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/1/dallas")
          .and_return(
            {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
            {body: JSON.dump("is_erroring" => false)},
          )

        mutex = Mutex.new
        var = ConditionVariable.new

        hostname = Hostname.new("db-d1")
        monitor = Monitor.new(hostname: hostname, tick: 1)

        expect(supervisor.start_exclusive_monitor(monitor)).to be_truthy
        expect(supervisor.start_exclusive_monitor(monitor)).to be_falsey
        expect(supervisor.start_exclusive_monitor(monitor)).to be_falsey
      end
    end
  end
end
