require "spec_helper"
require "replication_fixing/ignore_client"
require "replication_fixing/fixing_client"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe FixingClient do
    include Lita::RSpec

    let(:ignore_client) { IgnoreClient.new(Lita.redis) }
    let(:repfix_api_key) { "abc123".freeze }

    subject(:fixing_client) {
      FixingClient.new(
        repfix_url: "https://repfix.example",
        ignore_client: ignore_client,
        repfix_api_key: repfix_api_key,
      )
    }

    describe "#fix" do
      context "when the shard is ignored" do
        it "does nothing and returns a ShardIsIgnored result" do
          ignore_client.ignore(11)
          expect(fixing_client.fix(Hostname.new("db-s11"))).to be_kind_of(FixingClient::ShardIsIgnored)
        end

        it "returns an error if repfix returns an error" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("error" => "the world exploded"))

          result = fixing_client.fix(hostname)
          expect(result).to be_kind_of(FixingClient::ErrorCheckingFixability)
          expect(result.error).to eq("the world exploded")
        end

        it "returns an error if the shard is erroring and not fixable" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => false))

          result = fixing_client.fix(hostname)
          expect(result).to be_kind_of(FixingClient::ErrorCheckingFixability)
          expect(result.error).to eq("not fixable")
          expect(result.status).to eq("is_erroring" => true, "is_fixable" => false)
        end

        it "returns no error detected if the shard is not erroring" do
          hostname = Hostname.new("db-s11")
          stub_request(:get, "https://repfix.example/replication/fixes/for/db/11/seattle")
            .and_return(body: JSON.dump("is_erroring" => false))

          result = fixing_client.fix(hostname)
          expect(result).to be_kind_of(FixingClient::NoErrorDetected)
        end
      end
    end
  end
end
