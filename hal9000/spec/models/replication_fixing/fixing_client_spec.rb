require "spec_helper"
require "replication_fixing/fixing_client"
require "replication_fixing/shard"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe FixingClient do
    include Lita::RSpec

    let(:fixing_status_client) { FixingStatusClient.new("dfw", Lita.redis) }
    let(:logger) { Logger.new("/dev/null") }

    subject(:fixing_client) do
      FixingClient.new(
        repfix_url: "https://repfix.example",
        fixing_status_client: fixing_status_client,
        log: logger,
      )
    end

    describe "#fix" do
      it "returns an error if repfix returns an error" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("error" => true, "message" => "the world exploded"))

        result = fixing_client.fix(shard: hostname)
        expect(result).to be_kind_of(FixingClient::ErrorCheckingFixability)
        expect(result.error).to eq("the world exploded")
      end

      it "returns an error if the shard is erroring and not fixable" do
        hostname = Hostname.new("pardot0-dbshard2-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/2")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false))

        result = fixing_client.fix(shard: hostname)
        expect(result).to be_kind_of(FixingClient::NotFixable)
        expect(result.status).to eq("is_erroring" => true, "is_fixable" => false)
      end

      it "resets the status of the fixing if the error is no longer being fixed" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false, "fix" => { "active" => false }))

        fixing_status_client.set_active(shard: hostname, active: true)
        expect(fixing_status_client.status(shard: hostname).fixing?).to be_truthy
        expect(fixing_status_client.status(shard: hostname).started_at).to be

        fixing_client.fix(shard: hostname)
        expect(fixing_status_client.status(shard: hostname).fixing?).to be_falsey
        expect(fixing_status_client.status(shard: hostname).started_at).to be
      end

      it "returns no error detected if the shard is not erroring" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("is_erroring" => false))

        result = fixing_client.fix(shard: hostname)
        expect(result).to be_kind_of(FixingClient::NoErrorDetected)
      end

      it "keeps status about the error, if active" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:post, "https://repfix.example/replication/fix/db/11")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true }))

        fixing_client.fix(shard: hostname)
        expect(fixing_status_client.status(shard: hostname).fixing?).to be_truthy
        expect(fixing_status_client.status(shard: hostname).started_at.to_i).to be_within(1).of(Time.now.to_i)
      end

      it "keeps status about the error, if present and fixable" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))
        stub_request(:post, "https://repfix.example/replication/fix/db/11")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

        fixing_client.fix(shard: hostname)
        expect(fixing_status_client.status(shard: hostname).fixing?).to be_falsey
        expect(fixing_status_client.status(shard: hostname).started_at.to_i).to be_within(1).of(Time.now.to_i)
      end

      it "does not keep status about the error, if it's not fixable" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false))

        fixing_client.fix(shard: hostname)
        expect(fixing_status_client.status(shard: hostname).fixing?).to be_falsey
      end

      it "returns information about the fix in progress" do
        hostname = Hostname.new("pardot0-dbshard1-11-dfw")
        stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/1")
          .and_return(
            { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
            body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true }),
          )
        stub_request(:post, "https://repfix.example/replication/fix/db/11")
          .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

        result = fixing_client.fix(shard: hostname)
        expect(result).to be_kind_of(FixingClient::FixInProgress)
        expect(result.started_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "#cancel" do
      it "cancels the fix" do
        shard = Shard.new("db", 11, "dfw")

        request = stub_request(:post, "https://repfix.example/replication/fixes/cancel/11")
          .and_return(body: JSON.dump("is_canceled" => true, "message" => "All fixes canceled"))

        result = fixing_client.cancel(shard: shard)
        expect(result).to be_kind_of(FixingClient::CancelResult)
        expect(result.success?).to be_truthy
        expect(result.message).to eq("All fixes canceled")

        expect(request).to have_been_made
      end

      it "returns an error if the fix cannot be canceled" do
        shard = Shard.new("db", 11, "dfw")

        request = stub_request(:post, "https://repfix.example/replication/fixes/cancel/11")
          .and_return(status: 500, body: "")

        result = fixing_client.cancel(shard: shard)
        expect(result).to be_kind_of(FixingClient::CancelResult)
        expect(result.success?).to be_falsey
        expect(result.message).to match(/HTTP 500/)

        expect(request).to have_been_made
      end
    end
  end
end
