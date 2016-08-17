require "spec_helper"
require "replication_fixing/shard"
require "replication_fixing/ignore_client"

module ReplicationFixing
  RSpec.describe IgnoreClient do
    include Lita::RSpec

    describe "#ignoring?" do
      it "returns truthy if ignoring all of the keys" do
        client = IgnoreClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        expect(client.ignoring?(shard)).to be_falsey

        client.ignore_all
        expect(client.ignoring?(shard)).to eq(:all)
        expect(client.ignoring?(Shard.new("db", 12, "dfw"))).to eq(:all)
      end

      it "returns truthy if ignoring a particular shard" do
        client = IgnoreClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        expect(client.ignoring?(shard)).to be_falsey

        client.ignore(shard)
        expect(client.ignoring?(shard)).to eq(:shard)
        expect(client.ignoring?(Shard.new("whoisdb", 11, "dfw"))).to be_falsey
        expect(client.ignoring?(Shard.new("db", 12, "dfw"))).to be_falsey
      end
    end

    describe "#reset_ignore" do
      it "cancels the ignore for a given shard" do
        client = IgnoreClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        client.ignore(shard)

        expect(client.ignoring?(shard)).to be_truthy

        client.reset_ignore(shard)
        expect(client.ignoring?(shard)).to be_falsey
      end
    end

    describe "#skipped_errors_count" do
      it "returns the number of errors skipped while a global ignore is in effect" do
        client = IgnoreClient.new("dfw", Lita.redis)

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
