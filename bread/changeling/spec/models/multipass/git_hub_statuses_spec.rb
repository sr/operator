require "rails_helper"

RSpec.describe Multipass::GitHubStatuses, :type => :model do
  describe "github commit statuses" do
    let(:statuses_url) { %r{https://api.github.com/repos/heroku/changeling/statuses/.*} }

    before do
      stub_json_request(:get, statuses_url, [].to_json)
      stub_json_request(:get, "https://x:123@components.heroku.tools/apps.json", fixture_data("heimdall/apps"))
      Sidekiq::Testing.inline!
    end

    after do
      Sidekiq::Testing.fake!
    end

    it "creates a pending commit status when a pr is opened" do
      stubbed_request = stub_request(:post, statuses_url).with do |request|
        JSON.parse(request.body)["state"] == "pending"
      end
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      mp.save
      expect(stubbed_request).to have_been_requested
    end

    it "creates a pending commit status if a pull request receives more commits" do
      # First pending status from creation
      stub_json_request(:any, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582", "[]")
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      mp.save
      # Second commit status from synchronization
      stub_json_request(:any, "https://api.github.com/repos/heroku/changeling/statuses/c95e3c0492c0c0456c396389b97ea486fa32c9af", "[]")
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_synchronize"))
      mp.save
    end

    it "creates a successful commit status if a pull request is approved" do
      status_url = "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582"
      stub_request(:post, status_url)
      stubbed_request = stub_request(:post, status_url).with do |request|
        JSON.parse(request.body)["state"] == "success"
      end
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      mp.approve_github_commit_status!
      expect(stubbed_request).to have_been_requested
    end

    it "creates one successful commit status if a pull request is emergency approved" do
      status_url = "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582"
      stub_request(:post, status_url)
      stubbed_request = stub_request(:post, status_url).with do |request|
        JSON.parse(request.body)["state"] == "success"
      end
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      mp.save

      stub_chat(mp)
      stub_request(:post, "https://changeling:123@shuriken.heroku.tools/webhooks/changeling")

      mp.emergency_approve("yannick")
      expect(stubbed_request).to have_been_requested
    end

    it "creates the multipass with the title from the pull request" do
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      expect(mp.title).to eql "Webhooks events generator"
    end

    it "creates the multipass with the sha from the pull request" do
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      expect(mp.release_id).to eql "ffa01fcbf02757d6cae5d928c2315adbaa2ec582"
    end

    it "creates a failure commit status if a pull request is rejected" do
      stub_request(:post, "https://api.github.com/repos/heroku/changeling/statuses/ffa01fcbf02757d6cae5d928c2315adbaa2ec582")
      mp = Multipass.find_or_initialize_by_pull_request(decoded_fixture_data("github/pull_request_opened"))
      mp.failure_github_commit_status!
    end
  end

  describe "#commit_status_options" do
    let(:multipass) { Fabricate(:unreviewed_multipass) }

    context "when major change" do
      before do
        multipass.change_type = ChangeCategorization::MAJOR
      end

      it "knows when missing fields" do
        expect(multipass.commit_status_options[:description]).to include "Peer review ✗"
        expect(multipass.commit_status_options[:description]).to include "SRE approval ✗"
      end

      it "knows who's reviewed so far" do
        multipass.peer_reviewer = "Yannick"
        expect(multipass.commit_status_options[:description]).to include "SRE approval ✗"
        expect(multipass.commit_status_options[:description]).to include "Reviewed by Yannick"
      end

      it "knows when it's complete" do
        multipass.peer_reviewer = "Yannick"
        multipass.sre_approver = "Jonan"
        multipass.complete = true
        expect(multipass.commit_status_options[:description]).to eql "All requirements completed. Reviewed by Yannick, Jonan."
      end

      it "knows when it's rejected" do
        multipass.peer_reviewer = "Yannick"
        multipass.sre_approver = "Jonan"
        multipass.rejector = "Jon"
        expect(multipass.commit_status_options[:description]).to eql "Rejected by Jon"
      end
    end

    context "when minor change" do
      before do
        multipass.change_type = ChangeCategorization::STANDARD
      end

      it "knows when missing fields" do
        expect(multipass.commit_status_options[:description]).to include "Peer review ✗"
        expect(multipass.commit_status_options[:description]).to_not include "SRE approval"
      end

      it "knows who's reviewed so far" do
        multipass.peer_reviewer = "Yannick"
        expect(multipass.commit_status_options[:description]).to include "Reviewed by Yannick"
      end

      it "knows when it's complete" do
        multipass.peer_reviewer = "Yannick"
        multipass.complete = true
        expect(multipass.commit_status_options[:description]).to eql "All requirements completed. Reviewed by Yannick."
      end
    end

    context "when emergency change" do
      before do
        multipass.emergency_approver = "Yannick"
      end

      it "sets an emergency approved description" do
        expect(multipass.commit_status_options[:description]).to eql "Completed via emergency approval by Yannick."
      end
    end

    context "when untested but has needed reviews" do
      it "says it's waiting for CI" do
        multipass.change_type = ChangeCategorization::STANDARD
        multipass.peer_reviewer = "Yannick"
        multipass.testing = false
        expect(multipass.commit_status_options[:description]).to eql "Waiting for CI to complete."
      end
    end

    context "when missing fields other than testing and has needed reviews" do
      it "says it's waiting for CI" do
        multipass.change_type = ChangeCategorization::STANDARD
        multipass.peer_reviewer = "Yannick"
        multipass.impact = nil
        expect(multipass.commit_status_options[:description]).to eql "Missing fields: impact"
      end
    end
  end

  describe "github commit status worker" do
    let!(:multipass) { Fabricate.create(:incomplete_multipass, requester: "Jonan", reference_url: "github.com") }

    it "fires when a multipass is updated" do
      Sidekiq::Testing.inline! do
        multipass.peer_reviewer = "Yannick"
        multipass.save!
      end
    end
  end

  describe "#check_commit_statuses!" do
    let(:ref_url) { "https://github.com/heroku/changeling/pull/12" }

    let(:multipass) do
      Fabricate.build(:multipass,
                      testing: false,
                      reference_url: ref_url)
    end

    let(:statuses_url) { %r{https://api.github.com/repos/heroku/changeling/statuses/.*} }

    before do
    end

    it "sets testing to true if a commit status succeeded for CI" do
      status = {
        "state" => "success",
        "context" => "ci/circleci"
      }
      stub_json_request(:get, statuses_url, [status].to_json)
      expect do
        multipass.check_commit_statuses!
      end.to change { multipass.testing }.to(true)
    end

    it "sets testing to false if no commit status succeeded for CI" do
      status = {
        "state" => "failed",
        "context" => "ci/circleci"
      }
      stub_json_request(:get, statuses_url, [status].to_json)
      expect do
        multipass.check_commit_statuses!
      end.to_not change { multipass.testing }
    end
  end
end
