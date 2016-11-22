require "rails_helper"

RSpec.describe Clients::Heimdall do
  let(:heimdall) { Clients::Heimdall.new }
  let(:repo) { Repository.find("fake-owner/fake-repo") }

  context "#client" do
    it "includes the heimdall api token in the headers" do
      expect(heimdall.client.headers["Authorization"]).to include ENV["HEIMDALL_API_TOKEN"]
    end

    it "uses the heimdall api endpoint" do
      expect(heimdall.client.build_url.to_s).to eql ENV["HEIMDALL_API_URL"] + "/"
    end
  end

  context "#notify" do
    it "posts with the repo name and owner" do
      stub_chat_for_repo(repo)

      heimdall.notify(repo, {})

      expect(WebMock).to have_requested(:post, chat_url_from_repo(repo))
    end

    it "posts with the payload" do
      payload = { fake: "payload" }
      stub_chat_for_repo(repo)

      heimdall.notify(repo, payload)

      expect(WebMock).to have_requested(:post, chat_url_from_repo(repo))
    end
  end

  context "#apps" do
    it "makes a get request to the heimdall apps endpoint" do
      stub_heimdall_apps

      heimdall.apps

      expect(WebMock).to have_requested(:get, heimdall_apps_url)
    end
  end
end
