require "rails_helper"

describe GitHubCommitStatusWorker do
  let(:multipass) { Fabricate(:complete_multipass) }

  context "#perform" do
    before do
      expect(Multipass).to receive(:find).with(multipass.id).and_return(multipass)
      multipass.reference_url = "https://github.com/heroku/changeling/pull/32"
    end

    it "creates a failed status when the multipass is incomplete", :type => :webmock do
      multipass.complete = false
      multipass.peer_reviewer = "" # force it to be incomplete
      multipass.save!
      expect_any_instance_of(Clients::GitHub).to receive(:create_pending_commit_status)

      GitHubCommitStatusWorker.perform_now(multipass.id)
    end

    it "creates a success status when the multipass is incomplete", :type => :webmock do
      expect_any_instance_of(Clients::GitHub).to receive(:create_success_commit_status)

      GitHubCommitStatusWorker.perform_now(multipass.id)
    end
  end
end
