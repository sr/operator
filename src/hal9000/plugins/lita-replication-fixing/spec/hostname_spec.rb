require "spec_helper"
require "replication_fixing/hostname"

module ReplicationFixing
  RSpec.describe Hostname do
    describe "#shard" do
      it "returns whoisdb for whois servers" do
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").prefix).to eq("whoisdb")
      end

      it "returns db for DFW and PHX shard servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").prefix).to eq("db")
        expect(Hostname.new("pardot0-dbshard1-88-phx").prefix).to eq("db")
      end

      it "parses DFW and PHX servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").shard_id).to eq(88)
        expect(Hostname.new("pardot0-dbshard1-89-phx").shard_id).to eq(89)
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").shard_id).to eq(1)
        expect(Hostname.new("pardot0-whoisdb1-1-phx").shard_id).to eq(1)
      end
    end

    describe "#cluster_id" do
      it "returns the cluster ID for DFW and PHX servers" do
        expect(Hostname.new("pardot0-dbshard1-1-dfw").cluster_id).to eq(1)
        expect(Hostname.new("pardot0-dbshard1-1-phx").cluster_id).to eq(1)
        expect(Hostname.new("pardot0-dbshard2-1-dfw").cluster_id).to eq(2)
        expect(Hostname.new("pardot0-dbshard2-1-phx").cluster_id).to eq(2)
      end
    end

    describe "#datacenter" do
      it "parses DFW and PHX servers" do
        expect(Hostname.new("pardot0-dbshard1-88-dfw").datacenter).to eq("dfw")
        expect(Hostname.new("pardot0-dbshard1-89-phx").datacenter).to eq("phx")
        expect(Hostname.new("pardot0-whoisdb1-1-dfw").datacenter).to eq("dfw")
        expect(Hostname.new("pardot0-whoisdb1-1-phx").datacenter).to eq("phx")
      end
    end

    describe "equality" do
      it "tests for equality" do
        expect(Hostname.new("pardot0-dbshard1-1-dfw")).to eq(Hostname.new("pardot0-dbshard1-1-dfw"))
        expect(Hostname.new("pardot0-dbshard1-1-dfw")).to eql(Hostname.new("pardot0-dbshard1-1-dfw"))
        expect(Hostname.new("pardot0-dbshard1-1-dfw").hash).to eq(Hostname.new("pardot0-dbshard1-1-dfw").hash)

        expect(Hostname.new("pardot0-dbshard1-1-dfw")).not_to eq(Hostname.new("pardot0-dbshard1-2-dfw"))
        expect(Hostname.new("pardot0-dbshard1-1-dfw")).not_to eql(Hostname.new("pardot0-dbshard1-2-dfw"))
        expect(Hostname.new("pardot0-dbshard1-1-dfw").hash).not_to eq(Hostname.new("pardot0-dbshard1-2-dfw").hash)
      end
    end
  end
end
