require "spec_helper"
require "replication_fixing/shard"
require "replication_fixing/fixing_status_client"

module ReplicationFixing
  RSpec.describe FixingStatusClient do
    include Lita::RSpec

    describe "#status" do
      it "returns a status with fixing? == false if no fixing is going on" do
        client = FixingStatusClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        expect(client.status(shard: shard).fixing?).to be_falsey
      end

      it "returns a status with fixing? == true if fixing is going on" do
        client = FixingStatusClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        client.set_active(shard: shard, active: true)

        expect(client.status(shard: shard).fixing?).to be_truthy
        expect(client.status(shard: shard).started_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end

    describe "#reset" do
      it "deletes the status" do
        client = FixingStatusClient.new("dfw", Lita.redis)

        shard = Shard.new("db", 11, "dfw")
        client.set_active(shard: shard, active: true)

        expect(client.status(shard: shard).fixing?).to be_truthy

        client.reset(shard: shard)
        expect(client.status(shard: shard).fixing?).to be_falsey
      end
    end
  end

  describe "#current_fixes" do
    it "lists all of the shards currently being fixed" do
      shard11 = Shard.new("db", 11, "dfw")
      shard12 = Shard.new("db", 12, "dfw")

      client = FixingStatusClient.new("dfw", Lita.redis)
      client.set_active(shard: shard11, active: true)
      client.set_active(shard: shard12, active: true)

      fixes = client.current_fixes
      expect(fixes.length).to eq(2)
      expect(fixes[0].shard).to eq(shard11)
      expect(fixes[1].shard).to eq(shard12)
    end
  end
end
