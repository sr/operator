require "rails_helper"

describe Notifiers::Chat, :type => :webmock do
  let(:multipass) { Fabricate(:multipass) }

  let(:event) { new_release_create_event }
  let(:notifier) { Notifiers::Chat.new }
  let(:name_with_owner) { event.multipass.repository.name_with_owner }

  let(:heimdall_url) { "https://fake-heimdall.example.com/hubot-deploy" }

  let(:repo_url) { "#{heimdall_url}/repos/#{name_with_owner}/messages" }

  context "#client" do
    it "creates a caching instance variable for the client" do
      client = notifier.client
      expect(client).to be_a_kind_of(Clients::Heimdall)
      expect(client).to eql(notifier.client)
    end
  end

  context "#emergency_override" do
    let(:multipass) { event.multipass }

    before do
      multipass.emergency_approver = Faker::Internet.user_name
    end

    it "includes the actor in the payload" do
      body = {
        type: "override",
        data: {
          actor: multipass.emergency_approver,
          repo: name_with_owner,
          link: multipass.permalink
        }
      }

      stub_request(:post, repo_url)
        .with(body: body.to_json, headers: default_headers_for_chat_notifying)
        .to_return(status: 202, body: "")

      notifier.emergency_override(multipass)
    end
  end

  context "#deploy" do
    it "includes all atttributes in the payload" do
      body = {
        type: "event",
        data: {
          app_name: event.app_name,
          external_id: event.external_id,
          resource: event.resource,
          action: event.action,
          actor: event.payload_user,
          description: "Deploy #{event.release_sha}"
        }
      }

      stub_request(:post, repo_url)
        .with(body: body.to_json, headers: default_headers_for_chat_notifying)
        .to_return(status: 202, body: "")

      notifier.deploy(event)
    end
  end

  context "#override_name" do
    let(:multipass) { event.multipass }
    it "returns the repository name if it exists" do
      multipass.reference_url = "https://github.com/fake-owner/fake-repo/pull/42"
      result = notifier.override_name(multipass)
      expect(result).to eql multipass.repository_name
    end

    it "returns 'a multipass' if the reference_url is not github.com" do
      multipass.reference_url = "https://notgithub.com/fake-owner/fake-repo/pull/42"
      result = notifier.override_name(multipass)
      expect(result).to eql "a multipass"
    end
  end

  context "#override_link" do
    let(:multipass) { event.multipass }
    it "returns the multipass_url if the multipass is persisted" do
      result = notifier.override_link(multipass)
      expect(result).to eql multipass.permalink
    end

    it "returns the reference_url if the multipass is not persisted" do
      multipass = Fabricate.build(:multipass)
      result = notifier.override_link(multipass)
      expect(result).to eql multipass.reference_url
    end
  end

  context "#direwolf_deploy?" do
    it "returns false for production" do
      result = notifier.direwolf_deploy? "direwolf-production"
      expect(result).to be false
    end

    it "returns true for direwolf test apps" do
      result = notifier.direwolf_deploy? "direwolf-615197dc9d"
      expect(result).to be true
    end
  end

  context "#pr_app?" do
    it "returns true for pr app names" do
      result = notifier.pr_app? "fake-pr-app-pr-1234"
      expect(result).to be true
    end

    it "returns false for pr app names" do
      result = notifier.pr_app? "fake-app-not-from-pr"
      expect(result).to be false
    end
  end
end
