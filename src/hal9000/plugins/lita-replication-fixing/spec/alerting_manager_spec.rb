require "spec_helper"
require "replication_fixing/alerting_manager"
require "replication_fixing/test_pager"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe AlertingManager do
    let(:hostname) { Hostname.new("pardot0-dbshard1-1-dfw") }
    let(:pager) { TestPager.new }
    let(:log) { Logger.new("/dev/null") }

    subject(:manager) { AlertingManager.new(pager: pager, log: log) }

    describe "#ingest_fix_result" do
      it "pages when there is an error checking fixability" do
        pending "Not sure this is a good idea yet. We need to figure out what generally causes these alerts first"

        result = FixingClient::ErrorCheckingFixability.new(error: "everything is broken")

        manager.ingest_fix_result(shard_or_hostname: hostname, result: result)

        expect(pager.incidents[0]).to match(/#{hostname}/)
        expect(pager.incidents[0]).to match(/everything is broken/)
      end

      it "pages when a shard is not fixable" do
        result = FixingClient::NotFixable.new(status: {})

        manager.ingest_fix_result(shard_or_hostname: hostname, result: result)

        expect(pager.incidents[0]).to match(/#{hostname}/)
        expect(pager.incidents[0]).to match(/replication is not automatically fixable/)
      end

      it "does not page for other results" do
        result = FixingClient::FixInProgress.new

        manager.ingest_fix_result(shard_or_hostname: hostname, result: result)

        expect(pager.incidents[0]).to eq(nil)
      end
    end

    describe "#notify_replication_disabled_by_many_errors" do
      it "sends a page" do
        manager.notify_replication_disabled_but_many_errors
        expect(pager.incidents[0]).to match(/replication fixing is disabled, but many errors are still occurring/)
      end
    end

    describe "#notify_fixing_a_long_while" do
      it "sends a page" do
        twenty_minutes_ago = Time.now - 20 * 60

        manager.notify_fixing_a_long_while(shard: hostname.shard, started_at: twenty_minutes_ago)

        expect(pager.incidents[0]).to match(/#{hostname.shard}/)
        expect(pager.incidents[0]).to match(/automatic replication fixing has been going on for 2[01] minutes/)
      end
    end
  end
end
