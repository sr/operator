require "spec_helper"
require "replication_fixing/ignore_client"
require "replication_fixing/fixing_client"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe FixingClient do
    include Lita::RSpec

    let(:ignore_client) { IgnoreClient.new(Lita.redis) }
    let(:fixing_status_client) { FixingStatusClient.new(Lita.redis) }

    subject(:fixing_client) {
      FixingClient.new(
        repfix_url: "https://repfix.example",
        ignore_client: ignore_client,
        fixing_status_client: fixing_status_client,
      )
    }

    describe "#fix" do
      context "when fixing is globally ignored" do
        it "does nothing and returns a AllShardsIgnored result" do
          ignore_client.ignore_all
          expect(fixing_client.fix(hostname: Hostname.new("db-s11"))).to be_kind_of(FixingClient::AllShardsIgnored)
        end

        it "increments the skipped error count" do
          ignore_client.ignore_all
          expect(fixing_client.fix(hostname: Hostname.new("db-s11")).skipped_errors_count).to eq(1)
        end
      end

      context "when the shard is ignored" do
        it "does nothing and returns a ShardIsIgnored result" do
          ignore_client.ignore(11)
          expect(fixing_client.fix(hostname: Hostname.new("db-s11"))).to be_kind_of(FixingClient::ShardIsIgnored)
        end

        it "does not increment the skipped error count" do
          ignore_client.ignore(11)
          fixing_client.fix(hostname: Hostname.new("db-s11"))

          expect(ignore_client.skipped_errors_count).to eq(0)
        end
      end

      context "normal case" do
        it "returns an error if repfix returns an error" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("error" => "the world exploded"))

          result = fixing_client.fix(hostname: hostname)
          expect(result).to be_kind_of(FixingClient::ErrorCheckingFixability)
          expect(result.error).to eq("the world exploded")
        end

        it "returns an error if the shard is erroring and not fixable" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false))

          result = fixing_client.fix(hostname: hostname)
          expect(result).to be_kind_of(FixingClient::NotFixable)
          expect(result.status).to eq("is_erroring" => true, "is_fixable" => false)
        end

        it "returns no error detected if the shard is not erroring" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => false))

          result = fixing_client.fix(hostname: hostname)
          expect(result).to be_kind_of(FixingClient::NoErrorDetected)
        end

        it "keeps status about the error, if present and fixable" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))
          stub_request(:post, "https://repfix.example/replication/fix/db/11")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

          fixing_client.fix(hostname: hostname)
          expect(fixing_status_client.status(11).fixing?).to be_truthy
          expect(fixing_status_client.status(11).started_at.to_i).to be_within(1).of(Time.now.to_i)
        end

        it "does not keep status about the error, if it's not fixable" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false))

          fixing_client.fix(hostname: hostname)
          expect(fixing_status_client.status(11).fixing?).to be_falsey
        end

        it "returns information about the fix in progress if it's a new fix" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))
          stub_request(:post, "https://repfix.example/replication/fix/db/11")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

          result = fixing_client.fix(hostname: hostname)
          expect(result).to be_kind_of(FixingClient::FixInProgress)
          expect(result.new_fix).to be_truthy
          expect(result.started_at.to_i).to be_within(1).of(Time.now.to_i)
        end
      end
    end
  end
end
