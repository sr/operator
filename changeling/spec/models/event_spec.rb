require "rails_helper"

RSpec.describe Event do
  let(:payload) do
    {
      id: SecureRandom.uuid,
      data: { app: { name: "changeling-production" } },
      action: "create",
      actor: { email: "yannick@heroku.com" },
      resource: "release"
    }.with_indifferent_access
  end

  let(:event) { Event.new_from_payload(payload) }

  describe ".new_from_payload" do
    let!(:user) { User.create(github_login: "ys") }

    subject { Event.new_from_payload(payload) }

    it "has correct external_id" do
      expect(subject.external_id).to eql payload["id"]
    end

    it "has correct app_name" do
      expect(subject.app_name).to eql "changeling-production"
    end

    it "has correct resource" do
      expect(subject.resource).to eql "release"
    end

    it "has correct action" do
      expect(subject.action).to eql "create"
    end

    it "gets user mapping" do
      expect(subject.user).to eql user
    end

    it "has the full payload" do
      expect(subject.payload).to eql payload
    end
  end

  describe "#payload" do
    it "defaults to empty hash" do
      expect(Event.create.payload).to eql({})
      expect(Event.new.payload).to eql({})
    end
  end

  describe "#repository" do
    let(:multipass) { Fabricate(:multipass) }

    context "with a multipass" do
      it "returns the repository from the multipass if the event has a multipass" do
        payload[:data][:description] = "Deploy #{multipass.release_id}"
        event = Event.new_from_payload(payload)

        expect(event.repository.name_with_owner).to eql multipass.repository.name_with_owner
      end

      it "looks up the repo name by the app name if the event has an app name" do
        apps = fixture_data("heimdall/apps")
        stub_request(:get, heimdall_apps_url).to_return(body: apps, status: 200)

        expect(event.repository.name_with_owner).to eql "heroku/changeling"
      end

      it "returns a repo for unknown-app if the event does not have an app name" do
        apps = fixture_data("heimdall/apps")
        stub_request(:get, heimdall_apps_url).to_return(body: apps, status: 200)

        payload[:data][:app][:name] = nil
        event = Event.new_from_payload(payload)

        expect(event.repository.name_with_owner).to eql "heroku/unknown-app"
      end
    end
  end

  describe "#repo_name" do
    it "gets the repo name from Heimdall" do
      apps = fixture_data("heimdall/apps")
      stub_request(:get, heimdall_apps_url).to_return(body: apps, status: 200)

      expect(event.repo_name).to eql "heroku/changeling"
    end

    it "returns nil if it can't find the repo name" do
      apps = fixture_data("heimdall/apps")
      stub_request(:get, heimdall_apps_url).to_return(body: apps, status: 200)

      payload[:data][:app][:name] = "fake-app"
      event = Event.new_from_payload(payload)

      expect(event.repo_name).to be nil
    end
  end
end
