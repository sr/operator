require "spec_helper"
require "replication_fixing/datacenter_aware_registry"

module ReplicationFixing
  describe DatacenterAwareRegistry do
    describe "#register" do
      it "registers a client for the given datacenter" do
        dfw = Object.new

        registry = DatacenterAwareRegistry.new
        registry.register("dfw", dfw)

        expect(registry.for_datacenter("dfw")).to be(dfw)
      end

      it "raises an error if nothing is registered for the datacenter" do
        registry = DatacenterAwareRegistry.new
        expect do
          registry.for_datacenter("nope")
        end.to raise_error(DatacenterAwareRegistry::NoSuchDatacenter)
      end
    end
  end
end
