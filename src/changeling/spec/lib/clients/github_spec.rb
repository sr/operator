require "rails_helper"

RSpec.describe Clients::GitHub do
  subject(:client) { Clients::GitHub.new("token") }

  describe "#heroku_org_member?" do
    it "returns true when a member of the Heroku org" do
      body = [{ login: "heroku" }].to_json
      stub_json_request(:get, "https://api.github.com/user/orgs", body)
      expect(client.heroku_org_member?).to eq(true)
    end

    it "returns false when not a member of the Heroku org" do
      body = [{ login: "not-heroku" }].to_json
      stub_json_request(:get, "https://api.github.com/user/orgs", body)
      expect(client.heroku_org_member?).to_not eq(true)
    end
  end

  describe "#compliance_status" do
    it "returns a status when it exists" do
      sha = "036e7c5b7388b3738e1f0288dfa4e4b1a76d76e6"

      body = [{ context: "heroku/compliance", state: "pending" }].to_json
      stub_json_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/#{sha}", body)
      status = client.compliance_status("heroku/changeling", sha)
      expect(status.state).to eq("pending")
    end

    it "returns nil when it does not exist" do
      sha = "deadbeef"
      body = [{ context: "not-heroku/compliance", state: "pending" }].to_json
      stub_json_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/#{sha}", body)
      status = client.compliance_status("heroku/changeling", sha)
      expect(status).to eq(nil)
    end
  end

  describe "#compliance_status_exists?" do
    it "returns false if no status" do
      sha = "deadbeef"
      expect(client).to receive(:compliance_status).and_return(nil)
      expect(client.compliance_status_exists?("heroku/changeling", sha, "", "")).to eq(false)
    end
  end

  describe "#create_pending_commit_status", :type => :webmock do
    let(:sha) { "deadbeef" }
    let(:repo) { "heroku/changeling" }
    let(:options) do
      {
        context: "heroku/compliance",
        target_url: "https://changeling-staging.heroku.tools/multipasses/6a6a8fe1-0294-4762-b592-d88177efc73c",
        description: "Peer review ✗"
      }
    end

    it "does not post if the status won't change" do
      status = {
        context: "heroku/compliance",
        state: "pending",
        description: options[:description]
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)
      client.create_pending_commit_status(repo, sha, options)
    end

    it "posts if the status needs to change" do
      status = {
        context: "heroku/compliance",
        state: "pending",
        description: "NOT THE SAME AS NEXT ONE"
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/deadbeef")
        .with(body: hash_including("description" => options[:description]))
      client.create_pending_commit_status(repo, sha, options)
    end
  end

  describe "#create_success_commit_status", :type => :webmock do
    let(:sha) { "deadbeef" }
    let(:repo) { "heroku/changeling" }
    let(:options) do
      {
        context: "heroku/compliance",
        target_url: "https://changeling-staging.heroku.tools/multipasses/6a6a8fe1-0294-4762-b592-d88177efc73c",
        description: "Peer review ✗"
      }
    end

    it "does not post if the status won't change" do
      status = {
        context: "heroku/compliance",
        state: "success",
        description: options[:description]
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)
      client.create_success_commit_status(repo, sha, options)
    end

    it "posts if the status needs to change" do
      status = {
        context: "heroku/compliance",
        state: "pending",
        description: options[:description]
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)
      body = hash_including("state" => "success", "description" => options[:description])
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/deadbeef")
        .with(body: body)
      client.create_success_commit_status(repo, sha, options)
    end
  end

  describe "#create_failure_commit_status", :type => :webmock do
    let(:sha) { "deadbeef" }
    let(:repo) { "heroku/changeling" }
    let(:options) do
      {
        context: "heroku/compliance",
        target_url: "https://changeling-staging.heroku.tools/multipasses/6a6a8fe1-0294-4762-b592-d88177efc73c",
        description: "Rejected by deadbeef"
      }
    end

    it "does not post if the status won't change" do
      status = {
        context: "heroku/compliance",
        state: "failure",
        description: options[:description]
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)

      client.create_failure_commit_status(repo, sha, options)
    end

    it "posts if the status needs to change" do
      status = {
        context: "heroku/compliance",
        state: "pending",
        description: options[:description]
      }
      statuses_url = %r{https://api.github.com/repos/heroku/changeling/statuses/.*}
      stub_json_request(:get, statuses_url, [status].to_json)
      body = hash_including("state" => "failure", "description" => options[:description])
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/deadbeef")
        .with(body: body)

      client.create_failure_commit_status(repo, sha, options)
    end
  end

  describe "#commit_statuses" do
    let(:sha) { "036e7c5b7388b3738e1f0288dfa4e4b1a76d76e6" }
    let(:repo) { "heroku/changeling" }

    it "returns the github statuses for a sha" do
      body = [{ context: "heroku/compliance", state: "pending" }].to_json
      stub_json_request(:get, "https://api.github.com/repos/heroku/changeling/statuses/#{sha}", body)
      statuses = client.commit_statuses(repo, sha)
      expect(statuses.size).to eql(1)
    end
  end
end
