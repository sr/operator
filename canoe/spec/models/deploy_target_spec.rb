require "rails_helper"

RSpec.describe DeployTarget do
  describe "#lock!" do
    it "is a no-op if the lock is already held by the given user" do
      project = FactoryGirl.create(:project)
      target = FactoryGirl.create(:deploy_target)
      user = FactoryGirl.create(:user)

      lock1 = target.lock!(project, user)
      lock2 = target.lock!(project, user)

      expect(lock1).to eq(lock2)
    end
  end
end
