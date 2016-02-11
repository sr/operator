require "spec_helper"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe Hostname do
    describe "#prefix" do
      it "returns db for DAL and SEA shard servers" do
        expect(Hostname.new("db-d1").prefix).to eq("db")
        expect(Hostname.new("db-s1").prefix).to eq("db")
      end

      it "returns whoisdb for whois servers" do
        expect(Hostname.new("whoisdb-d1").prefix).to eq("whoisdb")
        expect(Hostname.new("whoisdb-s1").prefix).to eq("whoisdb")
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").prefix).to eq("whoisdb")
      end

      it "returns db for DFW and PHX shard servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").prefix).to eq("db")
        expect(Hostname.new("pardot0-dbshard1-88-phx").prefix).to eq("db")
      end
    end

    describe "#shard_id" do
      it "parses DAL and SEA servers" do
        expect(Hostname.new("db-d1").shard_id).to eq(1)
        expect(Hostname.new("db-s2").shard_id).to eq(2)
        expect(Hostname.new("whoisdb-d1").shard_id).to eq(1)
        expect(Hostname.new("whoisdb-s2").shard_id).to eq(2)
      end

      it "parses DFW and PHX servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").shard_id).to eq(88)
        expect(Hostname.new("pardot0-dbshard1-89-phx").shard_id).to eq(89)
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").shard_id).to eq(1)
        expect(Hostname.new("pardot0-whoisdb1-1-phx").shard_id).to eq(1)
      end
    end

    describe "#datacenter" do
      it "parses DAL and SEA servers" do
        expect(Hostname.new("db-d1").datacenter).to eq("dallas")
        expect(Hostname.new("db-s2").datacenter).to eq("seattle")
        expect(Hostname.new("whoisdb-d1").datacenter).to eq("dallas")
        expect(Hostname.new("whoisdb-s2").datacenter).to eq("seattle")
      end

      it "parses DFW and PHX servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").datacenter).to eq("dfw")
        expect(Hostname.new("pardot0-dbshard1-89-phx").datacenter).to eq("phx")
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").datacenter).to eq("dfw")
        expect(Hostname.new("pardot0-whoisdb1-1-phx").datacenter).to eq("phx")
      end
    end
  end
end
