require "rails_helper"

RSpec.describe Server do
  describe "#datacenter" do
    it "calculates datacenter based on hostname" do
      server = FactoryGirl.build(:server, hostname: "pardot0-app1-1-phx")
      server.save!
      expect(server.datacenter).to eq("phx")

      server = FactoryGirl.build(:server, hostname: "pardot0-app1-1-dfw")
      server.save!
      expect(server.datacenter).to eq("dfw")

      server = FactoryGirl.build(:server, hostname: "notvalid")
      expect(server.valid?).to be_falsey
      expect(server.errors).to have_key(:hostname)
    end

    it "calculates datacenter for legacy SoftLayer servers" do
      server = FactoryGirl.build(:server, hostname: "app-s1")
      server.save!
      expect(server.datacenter).to eq("softlayer")

      server = FactoryGirl.build(:server, hostname: "app-s1.dev")
      server.save!
      expect(server.datacenter).to eq("softlayer")
    end
  end
end
