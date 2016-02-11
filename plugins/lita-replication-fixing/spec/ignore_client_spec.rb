require "spec_helper"
require "replication_fixing/ignore_client"

module ReplicationFixing
  RSpec.describe IgnoreClient do
    include Lita::RSpec

    describe "#ignoring?" do
      it "returns true if ignoring all of the keys" do
        client = IgnoreClient.new(Lita.redis)
        expect(client.ignoring?(11)).to be_falsey

        client.ignore_all
        expect(client.ignoring?(11)).to be_truthy
        expect(client.ignoring?(12)).to be_truthy
      end

      it "returns true if ignoring a particular shard" do
        client = IgnoreClient.new(Lita.redis)
        expect(client.ignoring?(11)).to be_falsey

        client.ignore(11)
        expect(client.ignoring?(11)).to be_truthy
        expect(client.ignoring?(12)).to be_falsey
      end
    end
  end
end
