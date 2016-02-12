require "spec_helper"
require "replication_fixing/ignore_client"

module ReplicationFixing
  RSpec.describe IgnoreClient do
    include Lita::RSpec

    describe "#ignoring?" do
      it "returns truthy if ignoring all of the keys" do
        client = IgnoreClient.new(Lita.redis)
        expect(client.ignoring?(11)).to be_falsey

        client.ignore_all
        expect(client.ignoring?(11)).to eq(:all)
        expect(client.ignoring?(12)).to eq(:all)
      end

      it "returns truthy if ignoring a particular shard" do
        client = IgnoreClient.new(Lita.redis)
        expect(client.ignoring?(11)).to be_falsey

        client.ignore(11)
        expect(client.ignoring?(11)).to eq(:shard)
        expect(client.ignoring?(12)).to be_falsey
      end
    end

    describe "#skipped_errors_count" do
      it "returns the number of errors skipped while a global ignore is in effect" do
        client = IgnoreClient.new(Lita.redis)

        client.ignore_all
        expect(client.skipped_errors_count).to eq(0)

        expect(client.incr_skipped_errors_count).to eq(1)
        expect(client.incr_skipped_errors_count).to eq(2)

        client.reset_ignore_all
        expect(client.skipped_errors_count).to eq(0)
      end
    end
  end
end
