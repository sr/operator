require "spec_helper"
require "replication_fixing/fixing_status_client"

module ReplicationFixing
  RSpec.describe FixingStatusClient do
    include Lita::RSpec

    describe "#status" do
      it "returns a status with fixing? == false if no fixing is going on" do
        client = FixingStatusClient.new(Lita.redis)
        expect(client.status(11).fixing?).to be_falsey
      end

      it "returns a status with fixing? == true if fixing is going on" do
        client = FixingStatusClient.new(Lita.redis)
        client.ensure_fixing_status_ongoing(11)

        expect(client.status(11).fixing?).to be_truthy
        expect(client.status(11).started_at.to_i).to be_within(1).of(Time.now.to_i)
      end
    end
  end
end
