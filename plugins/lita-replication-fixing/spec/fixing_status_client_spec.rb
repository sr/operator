require "spec_helper"
require "replication_fixing/shard"
require "replication_fixing/fixing_status_client"

module ReplicationFixing
  RSpec.describe FixingStatusClient do
    include Lita::RSpec

    describe "#status" do
      it "returns a status with fixing? == false if no fixing is going on" do
        client = FixingStatusClient.new(Lita.redis)

        shard = Shard.new("db", 11)
        expect(client.status(shard: shard).fixing?).to be_falsey
      end

      it "returns a status with fixing? == true if fixing is going on" do
        client = FixingStatusClient.new(Lita.redis)

        shard = Shard.new("db", 11)
        client.ensure_fixing_status_ongoing(shard: shard)

        expect(client.status(shard: shard).fixing?).to be_truthy
        expect(client.status(shard: shard).started_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "#reset_status" do
      it "deletes the status" do
        client = FixingStatusClient.new(Lita.redis)

        shard = Shard.new("db", 11)
        client.ensure_fixing_status_ongoing(shard: shard)

        expect(client.status(shard: shard).fixing?).to be_truthy

        client.reset_status(shard: shard)
        expect(client.status(shard: shard).fixing?).to be_falsey
      end
    end
  end
end
