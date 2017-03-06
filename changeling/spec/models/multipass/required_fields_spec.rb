require "rails_helper"

RSpec.describe Multipass::RequiredFields, :type => :model do
  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }
  let(:incomplete_multipass) { Fabricate.build(:incomplete_multipass) }

  describe "#missing_fields" do
    let(:mandatory_fields) { [:reference_url, :requester, :impact, :impact_probability, :change_type, :testing, :backout_plan] }

    it "returns missing mandatory fields" do
      mandatory_fields.each do |f|
        expect(Multipass.new.missing_fields).to include(f)
      end
    end

    context "conditional fields" do
      it "returns missing fields for major changes" do
        incomplete_multipass.change_type = ChangeCategorization::MAJOR
        expect(incomplete_multipass.missing_fields).to include(:peer_reviewer)
        expect(incomplete_multipass.missing_fields).to include(:sre_approver)
      end

      it "returns missing fields for minor changes" do
        incomplete_multipass.change_type = ChangeCategorization::STANDARD
        expect(incomplete_multipass.missing_fields).to include(:peer_reviewer)
      end
    end
  end

  describe "#required_field?" do
    context "with a major change" do
      before do
        incomplete_multipass.update_attributes(change_type: ChangeCategorization::MAJOR)
      end

      it "returns true for sre_approver" do
        expect(incomplete_multipass.required_field?(:sre_approver)).to be true
      end

      it "returns true for peer_reviewer" do
        expect(incomplete_multipass.required_field?(:peer_reviewer)).to be true
      end
    end

    context "with a minor change" do
      before do
        incomplete_multipass.update_attributes(change_type: ChangeCategorization::STANDARD)
      end

      it "returns false for sre_approver" do
        expect(incomplete_multipass.required_field?(:sre_approver)).to be false
      end

      it "returns true for peer_reviewer" do
        expect(incomplete_multipass.required_field?(:peer_reviewer)).to be true
      end
    end

    context "with an emergency change" do
      before do
        incomplete_multipass.update_attributes(change_type: ChangeCategorization::EMERGENCY)
      end

      it "returns false for sre_approver" do
        expect(incomplete_multipass.required_field?(:sre_approver)).to be false
      end

      it "returns false for peer_reviewer" do
        expect(incomplete_multipass.required_field?(:peer_reviewer)).to be false
      end
    end
  end

  describe "#enabled_actor?" do
    it "returns true if the actor is required" do
      allow(incomplete_multipass).to receive(:required_field?).and_return true
      expect(incomplete_multipass.enabled_actor?("fake-actor")).to be true
    end

    it "returns true if the actor is rejector" do
      allow(incomplete_multipass).to receive(:required_field?).and_return false
      expect(incomplete_multipass.enabled_actor?("rejector")).to be true
    end
  end

  describe "#locking_field?" do
    it "returns true if the field is in locking fields" do
      expect(incomplete_multipass.locking_field?(:rejector)).to be
      expect(incomplete_multipass.locking_field?(:emergency_approver)).to_not be
      expect(incomplete_multipass.locking_field?(:rejector, 2)).to be
      expect(incomplete_multipass.locking_field?(:emergency_approver, 2)).to be
    end

    it "returns false if the field is not in locking fields" do
      expect(incomplete_multipass.locking_field?(:fake_locking_field)).to_not be
      expect(incomplete_multipass.locking_field?(:fake_locking_field, 2)).to_not be
    end
  end
end
