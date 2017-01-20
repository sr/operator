require "rails_helper"

RSpec.describe Multipass::Updates, :type => :model do
  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }
  let(:incomplete_multipass) { Fabricate.build(:incomplete_multipass) }

  describe "#update_from_form" do
    let(:multipass_attributes) do
      {
        "impact" => complete_multipass.impact,
        "impact_probability" => complete_multipass.impact_probability,
        "change_type" => complete_multipass.change_type,
        "testing" => complete_multipass.testing ? "1" : "0",
        "backout_plan" => complete_multipass.backout_plan
      }
    end

    it "updates the impact" do
      new_impact = "test"
      complete_multipass.impact = nil
      multipass_attributes["impact"] = new_impact

      complete_multipass.update_from_form(multipass_attributes)
      expect(complete_multipass.impact).to eql new_impact
    end

    it "updates the impact_probability" do
      new_probability = ChangeCategorization::LIKELIHOOD_LOW
      complete_multipass.impact_probability = nil
      multipass_attributes["impact_probability"] = new_probability

      complete_multipass.update_from_form(multipass_attributes)
      expect(complete_multipass.impact_probability).to eql new_probability
    end

    it "updates the change_type" do
      new_type = ChangeCategorization::STANDARD
      complete_multipass.change_type = nil
      multipass_attributes["change_type"] = new_type

      complete_multipass.update_from_form(multipass_attributes)
      expect(complete_multipass.change_type).to eql new_type
    end

    it "updates the testing" do
      complete_multipass.update_attributes(testing: nil)
      multipass_attributes["testing"] = "1"

      complete_multipass.update_from_form(multipass_attributes)
      expect(complete_multipass.testing).to eql true
    end

    it "updates the backout_plan" do
      new_plan = Faker::Lorem.paragraph
      complete_multipass.update_attributes(backout_plan: nil)
      multipass_attributes["backout_plan"] = new_plan

      complete_multipass.update_from_form(multipass_attributes)
      expect(complete_multipass.backout_plan).to eql new_plan
    end

    it "reconciles testing with GitHub to complete multipasses" do
      create_changeling_multipass_from_pr fixture_data("github/changeling_commit_statuses")
      multipass = Multipass.first
      multipass_attributes["testing"] = "0"

      expect do
        multipass.update_from_form(multipass_attributes)
      end.to change { multipass.complete }.from(false).to(true)
    end
  end

  describe "#update_emergency_approver" do
    it "updates the emergency approver" do
      stub_chat(complete_multipass)
      complete_multipass.save
      complete_multipass.emergency_approve(user)
      expect(complete_multipass.emergency_approver).to eql user
    end

    it "creates an emergency override notification" do
      allow(ActiveSupport::Notifications).to receive(:instrument)
      expect(ActiveSupport::Notifications).to receive(:instrument).with("multipass.emergency_override", multipass: complete_multipass)
      complete_multipass.emergency_approve(user)
    end
  end
end
