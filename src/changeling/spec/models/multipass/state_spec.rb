require "rails_helper"

RSpec.describe Multipass, "state", type: [:model, :webmock] do
  before(:each) do
    Changeling.config.pardot = false
  end

  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }
  let(:incomplete_multipass) { Fabricate.build(:incomplete_multipass) }

  describe "#complete?" do
    context "when a major change" do
      before do
        @multipass = Fabricate.build(:multipass)
        @multipass.testing = true
        complete_multipass.change_type = :major
      end

      it "returns false without sre approval" do
        complete_multipass.sre_approver = ""
        expect(complete_multipass.complete?).to eq(false)
      end

      it "returns false without peer review" do
        complete_multipass.peer_reviewer = ""
        expect(complete_multipass.complete?).to eq(false)
      end

      it "returns true when approvals are present" do
        expect(complete_multipass.complete?).to eq(true)
      end
    end

    context "when a minor change" do
      before do
        complete_multipass.change_type = :minor
        complete_multipass.sre_approver = ""
      end

      it "returns false without peer review" do
        complete_multipass.peer_reviewer = ""
        expect(complete_multipass.complete?).to eq(false)
      end

      it "returns true when approvals are present" do
        expect(complete_multipass.complete?).to eq(true)
      end
    end

    context "with an emergency approver" do
      it "returns true" do
        incomplete_multipass.emergency_approver = user
        expect(incomplete_multipass.complete?).to be true
      end
    end

    it "returns false when there's no testing" do
      complete_multipass.testing = false
      expect(complete_multipass.complete?).to eq(false)
    end

    it "returns false when there's no backout plan" do
      complete_multipass.backout_plan = nil
      expect(complete_multipass.complete?).to eq(false)
    end

    it "returns false when there's no impact" do
      complete_multipass.impact = nil
      expect(complete_multipass.complete?).to eq(false)
    end

    it "returns false when there's no impact probability" do
      complete_multipass.impact_probability = nil
      expect(complete_multipass.complete?).to eq(false)
    end

    it "returns false when there's no change type" do
      complete_multipass.change_type = nil
      expect(complete_multipass.complete?).to eq(false)
    end

    it "is persisted even if calculated in model" do
      multipass = Fabricate(:multipass)
      stub_chat(multipass)

      multipass.emergency_approve(user)

      expect(multipass.reload.complete).to be true
      multipass.update_attribute(:testing, false)
      multipass.update_attribute(:emergency_approver, nil)
      expect(multipass.reload.complete).to be false
    end
  end

  describe "#pending?" do
    it "returns true for incomplete multipasses that have not been merged" do
      incomplete_multipass.merged = false
      expect(incomplete_multipass.pending?).to be true
    end

    it "returns false for incomplete multipasses that have been merged" do
      incomplete_multipass.merged = true
      expect(incomplete_multipass.pending?).to be false
    end

    it "returns false for complete multipasses whether or not they've been merged" do
      [true, false].each do |merged|
        complete_multipass.merged = merged
        expect(complete_multipass.pending?).to be false
      end
    end
  end

  describe "#rejected?" do
    it "returns true if the rejector is set" do
      incomplete_multipass.rejector = "fake-rejector"
      expect(incomplete_multipass.rejected?).to be true
    end

    it "returns false if the rejector is nil" do
      incomplete_multipass.rejector = nil
      expect(incomplete_multipass.rejected?).to be false
    end
  end

  describe "#status" do
    it "returns complete for multipasses that are complete" do
      allow(complete_multipass).to receive(:complete?).and_return true
      expect(complete_multipass.status).to eql "complete"
    end

    it "returns pending for multipasses that are pending" do
      complete_multipass.testing = nil
      expect(complete_multipass.status).to eql "pending"
    end

    it "returns incomplete for multipasses that aren't complete or pending" do
      complete_multipass.testing = false
      complete_multipass.merged = true
      complete_multipass.rejector = nil
      expect(complete_multipass.status).to eql "incomplete"
    end
  end
end
