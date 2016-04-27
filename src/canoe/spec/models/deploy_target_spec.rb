require "rails_helper"

RSpec.describe DeployTarget do
  describe "#lock!" do
    it "is a no-op if the lock is already held by the given user" do
      repo = FactoryGirl.create(:repo)
      target = FactoryGirl.create(:deploy_target)
      user = FactoryGirl.create(:user)

      lock1 = target.lock!(repo, user)
      lock2 = target.lock!(repo, user)

      expect(lock1).to eq(lock2)
    end
  end
end
