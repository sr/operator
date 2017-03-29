require "rails_helper"

RSpec.describe DeployNotification do
  let(:deploy) { FactoryGirl.create(:deploy) }
  let(:notification) { FactoryGirl.create(:deploy_notification) }
  let(:notifier) { FakeHipchatNotifier.new }

  before do
    notification.notifier = notifier
  end

  describe "#notify_deploy_start" do
    it "notifies a HipChat room" do
      notification.notify_deploy_start(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/just began syncing/)
    end

    it "notifies a HipChat room in a flashy way if a pending build is deployed" do
      deploy.update!(passed_ci: false)

      notification.notify_deploy_start(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].color).to eq("red")
      expect(notifier.messages[0].message).to match(/PENDING BUILD/)
    end

    it "notifies a HipChat room with full_project_name if the project has a topology set in the options" do
      deploy.update!(project_name: "murdoc", options: { "topology" => "action-topo:murdoc.processing.topology.ActionApplicationTopology" })
      notification.notify_deploy_start(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/just began syncing Murdoc \(action-topo\)/)
    end
  end

  describe "#notify_deploy_complete" do
    it "notifies a HipChat room" do
      notification.notify_deploy_complete(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/just finished syncing/)
    end

    it "notifies a HipChat room with full_project_name if the project has a topology set in the options" do
      deploy.update!(project_name: "murdoc", options: { "topology" => "action-topo:murdoc.processing.topology.ActionApplicationTopology" })
      notification.notify_deploy_complete(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/just finished syncing Murdoc \(action-topo\)/)
    end
  end

  describe "#notify_deploy_cancelled" do
    it "notifies a HipChat room" do
      notification.notify_deploy_cancelled(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/CANCELLED syncing/)
    end

    it "notifies a HipChat room with full_project_name if the project has a topology set in the options" do
      deploy.update!(project_name: "murdoc", options: { "topology" => "action-topo:murdoc.processing.topology.ActionApplicationTopology" })
      notification.notify_deploy_cancelled(deploy)
      expect(notifier.messages.size).to eq(1)
      expect(notifier.messages[0].room_id).to eq(notification.hipchat_room_id)
      expect(notifier.messages[0].message).to match(/CANCELLED syncing Murdoc \(action-topo\)/)
    end
  end
end