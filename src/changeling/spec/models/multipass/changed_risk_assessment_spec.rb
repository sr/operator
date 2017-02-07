require "rails_helper"

RSpec.describe "Multipass#changed_risk_assessment?", type: [:model, :webmock] do
  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }

  describe "#changed_risk_assessment?" do
    it "returns true if change_type is not default" do
      complete_multipass.save
      complete_multipass.update(impact: ChangeCategorization::LIKELIHOOD_MEDIUM)
      expect(complete_multipass).to be_changed_risk_assessment
    end

    it "returns false if the change_type is default" do
      complete_multipass.save
      expect(complete_multipass).to_not be_changed_risk_assessment
    end
  end
end
