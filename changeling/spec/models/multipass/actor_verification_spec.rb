require "rails_helper"

RSpec.describe Multipass::ActorVerification, :type => :model do
  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }
  let(:incomplete_multipass) { Fabricate.build(:incomplete_multipass) }

  describe "#requested_by?" do
    it "returns true if the user and the requester match" do
      expect(complete_multipass.requested_by?(complete_multipass.requester)).to be true
    end

    it "returns true if the user has the same heroku email as the requester" do
      email = "test@heroku.com"
      complete_multipass.update_attributes(requester: email)
      allow(User).to receive(:for_github_login).with(user).and_return email
      expect(complete_multipass.requested_by?(user)).to be true
    end

    it "returns false if the user is not the same as the requester" do
      expect(complete_multipass.requested_by?(user)).to be false
    end
  end

  describe "#same_actor?" do
    %w{requester sre_approver peer_reviewer}.each do |actor|
      it "returns true if #{actor} matches the user" do
        expect(complete_multipass.same_actor?(actor, complete_multipass.send(actor))).to be true
      end

      it "returns true if the user has the same email as the #{actor}" do
        email = "test@heroku.com"
        complete_multipass.update_attributes(actor => email)
        allow(User).to receive(:for_github_login).with(user).and_return email
        expect(complete_multipass.same_actor?(actor, user)).to be true
      end
    end
  end
end
