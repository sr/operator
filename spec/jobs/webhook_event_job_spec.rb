require "rails_helper"

describe WebhookEventJob do
  let(:multipass) { Fabricate(:multipass, release_id: SecureRandom.hex(7)) }

  context "#perform" do
    let(:body) do
      {
        id: SecureRandom.uuid,
        app_name: "limerick-test-app",
        sha: multipass.release_id,
        user_email: "yannick@heroku.com"
      }.to_json
    end

    before do
      stub_chat(multipass)
    end

    it "creates a new event from payload" do
      expect do
        WebhookEventJob.new.perform(body)
      end.to change { Event.count }.by(1)
    end

    it "sets multipass" do
      WebhookEventJob.new.perform(body)
      expect(Event.last.multipass).to eql multipass
    end

    it "sets user" do
      u = User.create(github_login: "ys")
      WebhookEventJob.new.perform(body)
      expect(Event.last.user).to eql u
    end

    it "sets app_name" do
      WebhookEventJob.new.perform(body)
      expect(Event.last.app_name).to eql "limerick-test-app"
    end

    it "creates a deploy notification" do
      expect(ActiveSupport::Notifications).to receive(:instrument).with("application.release", anything)
      WebhookEventJob.new.perform(body)
    end
  end
end
