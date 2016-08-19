require "spec_helper"
require "thread"
require "replication_fixing/shard"
require "replication_fixing/monitor_supervisor"

module ReplicationFixing
  RSpec.describe MonitorSupervisor do
    include Lita::RSpec

    let(:fixing_status_client) { FixingStatusClient.new("dfw", Lita.redis) }
    let(:logger) { Logger.new("/dev/null") }

    let(:fixing_client) do
      FixingClient.new(
        repfix_url: "https://repfix.example",
        fixing_status_client: fixing_status_client,
        log: logger,
      )
    end

    subject(:supervisor) { MonitorSupervisor.new(redis: Lita.redis, fixing_client: fixing_client) }

    describe "#start_exclusive_monitor" do
      it "monitors the host every <tick> seconds, until it is fixed" do
        # 1) Fixable error
        # 2) Fix active
        # 3) No longer erroring
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/2")
          .and_return(
            { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
            { body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true }) },
            body: JSON.dump("is_erroring" => false),
          )

        mutex = Mutex.new
        var = ConditionVariable.new

        shard = Shard.new("db", 2, "dfw")
        monitor = Monitor.new(shard: shard, tick: 0.001)

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
          raise "Monitor never signaled the fix was completed" unless fixed

          expect(results.length).to eq(3)
        end
      end

      it "doesn't start a new monitor if one already exists" do
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/1/dfw")
          .and_return(
            { body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true }) },
            body: JSON.dump("is_erroring" => false),
          )

        mutex = Mutex.new
        var = ConditionVariable.new

        shard = Shard.new("db", 1, "dfw")
        monitor = Monitor.new(shard: shard, tick: 1)

        expect(supervisor.start_exclusive_monitor(monitor)).to be_truthy
        expect(supervisor.start_exclusive_monitor(monitor)).to be_falsey
        expect(supervisor.start_exclusive_monitor(monitor)).to be_falsey
      end
    end
  end
end
