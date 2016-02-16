require "spec_helper"
require "replication_fixing/alerting_manager"
require "replication_fixing/test_pager"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe AlertingManager do
    let(:hostname) { Hostname.new("db-d1") }
    let(:pager) { TestPager.new }
    let(:log) { Logger.new("/dev/null") }

    subject(:manager) { AlertingManager.new(pager: pager, log: log) }

    describe "#ingest_fix_result" do
      it "pages when there is an error checking fixability" do
        result = FixingClient::ErrorCheckingFixability.new(error: "everything is broken")

        manager.ingest_fix_result(hostname: hostname, result: result)

        expect(pager.incidents[0]).to match(/#{hostname}/)
        expect(pager.incidents[0]).to match(/everything is broken/)
      end

      it "pages when a shard is not fixable" do
        result = FixingClient::NotFixable.new(status: {})

        manager.ingest_fix_result(hostname: hostname, result: result)

        expect(pager.incidents[0]).to match(/#{hostname}/)
        expect(pager.incidents[0]).to match(/replication is not automatically fixable/)
      end

      it "pages if fixing is globally disabled and a lot of errors have occurred" do
        result = FixingClient::AllShardsIgnored.new(400)

        manager.ingest_fix_result(hostname: hostname, result: result)

        expect(pager.incidents[0]).to match(/replication fixing is disabled, but many errors/)
      end

      it "does not page if fixing is globally disabled and only a few errors have occurred" do
        result = FixingClient::AllShardsIgnored.new(42)

        manager.ingest_fix_result(hostname: hostname, result: result)

        expect(pager.incidents[0]).to eq(nil)
      end

      it "does not page for other results" do
        result = FixingClient::ShardIsIgnored.new

        manager.ingest_fix_result(hostname: hostname, result: result)

        expect(pager.incidents[0]).to eq(nil)
      end
    end

    describe "#notify_fixing_a_long_while" do
      it "sends a page" do
        twenty_minutes_ago = Time.now - 20*60

        manager.notify_fixing_a_long_while(hostname: hostname, started_at: twenty_minutes_ago)

        expect(pager.incidents[0]).to match(/#{hostname}/)
        expect(pager.incidents[0]).to match(/automatic replication fixing has been going on for 2[01] minutes/)
      end
    end
  end
end
