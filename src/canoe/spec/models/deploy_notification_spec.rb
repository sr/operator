require "rails_helper"

RSpec.describe DeployNotification do
  let(:deploy) { FactoryGirl.create(:deploy) }
  let(:notification) { FactoryGirl.create(:deploy_notification) }

  describe "#notify_deploy_start" do
    it "notifies a HipChat room" do
      expect(Hipchat).to receive(:notify_room)
        .with(1, /just began syncing/, deploy.deploy_target.production?)

      notification.notify_deploy_start(deploy)
    end
  end

  describe "#notify_deploy_complete" do
    it "notifies a HipChat room" do
      expect(Hipchat).to receive(:notify_room)
        .with(1, /just finished syncing/, deploy.deploy_target.production?)

      notification.notify_deploy_complete(deploy)
    end
  end

  describe "#notify_deploy_cancelled" do
    it "notifies a HipChat room" do
      expect(Hipchat).to receive(:notify_room)
        .with(1, /CANCELLED syncing/, deploy.deploy_target.production?)

      notification.notify_deploy_cancelled(deploy)
    end
  end

  describe "#notify_untested_deploy" do
    it "notifies a HipChat room" do
      expect(Hipchat).to receive(:notify_room)
        .with(1, /UNTESTED deploy/, deploy.deploy_target.production?, "red")

      notification.notify_untested_deploy(deploy)
    end
  end
end
