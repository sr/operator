require "rails_helper"

RSpec.describe RepositoryPullRequest do
  before(:each) do
    Changeling.config.pardot = true
    reference_url = format("https://%s/%s/pull/32",
      Changeling.config.github_hostname,
      PardotRepository::CHANGELING
    )
    @multipass = Fabricate(:multipass,
      reference_url: reference_url,
      release_id: "deadbeef",
      testing: nil
    )
    @repository_pull_request = RepositoryPullRequest.new(@multipass)
  end

  after(:each) do
    Changeling.config.pardot = false
  end

  def stub_jira_ticket(external_id, exists: true, resolved: false)
    if exists
      issue = decoded_fixture_data("jira/issue")
      issue["key"] = external_id
      issue["fields"]["resolution"] = nil unless resolved
      stub_request(:get, "https://sa_changeling:fakefakefake@jira.dev.pardot.com/rest/api/2/issue/#{external_id}")
        .to_return(body: JSON.dump(issue), headers: { "Content-Type" => "application/json" })
    else
      stub_request(:get, "https://sa_changeling:fakefakefake@jira.dev.pardot.com/rest/api/2/issue/#{external_id}")
        .to_return(body: JSON.dump({}), status: 404, headers: { "Content-Type" => "application/json" })
    end
  end

  def stub_github_pull_request(title: nil, merge_commit_sha: nil)
    pull_request = decoded_fixture_data("github/pull_request")
    pull_request["head"]["sha"] = @multipass.release_id
    pull_request["title"] = title if title
    if merge_commit_sha
      pull_request["merged"] = true
      pull_request["merge_commit_sha"] = merge_commit_sha
    end
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{PardotRepository::CHANGELING}/pulls/#{@multipass.pull_request_number}")
      .to_return(body: JSON.dump(pull_request), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_commit_status(statuses: [])
    combined_status = {
      repository: {
        id: 1
      },
      sha: @multipass.release_id,
      statuses: statuses
    }

    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{PardotRepository::CHANGELING}/commits/#{@multipass.release_id}/status")
      .to_return(body: JSON.dump(combined_status), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_pull_request_reviews(reviews = [])
    login_form = <<-EOS
      <form method="post" action="/session">
        <input type="text" name="login">
        <input type="password" name="password">
        <input type="submit">
      </form>
    EOS
    stub_request(:get, "https://#{Changeling.config.github_hostname}/login")
      .to_return(body: login_form, headers: { "Content-Type" => "text/html" })
    stub_request(:post, "https://#{Changeling.config.github_hostname}/session")

    reviews_html = reviews.map { |r|
      <<-EOS
        <div class="merge-status-item">
          <img alt="@#{r[:github_login]}">
          <span class="text-gray">#{r[:github_login]} #{r[:approved] ? "approved these changes" : "requested changes"}</span>
        </div>
      EOS
    }

    body = <<-EOS
    <div class="mergeability-details">
      <div class="branch-action-item">
        #{reviews_html.join("\n")}
      </div>
    </div>
    EOS

    stub_request(:get, "https://#{Changeling.config.github_hostname}/#{PardotRepository::CHANGELING}/pull/#{@multipass.pull_request_number}")
      .to_return(body: body, headers: { "Content-Type" => "text/html" })
  end

  describe "synchronizing ticket references" do
    it "creates a ticket references for JIRA tickets" do
      expect(@multipass.ticket_reference).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      expect(@multipass.reload.ticket_reference).to_not eq(nil)
      reference = @multipass.reload.ticket_reference
      expect(reference.open?).to eq(true)
      expect(reference.ticket_url).to eq("https://jira.dev.pardot.com/browse/BREAD-1598")
    end

    it "detects most common ticket ID - title separators" do
      expect(@multipass.ticket_reference).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598: hello")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "[BREAD-1598] - hello")
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)
    end

    it "updates existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      stub_jira_ticket("PDT-98")
      stub_github_pull_request(title: "PDT-98 Fix everything")
      @multipass.synchronize

      reference = @multipass.reload.ticket_reference
      expect(reference).to_not eq(nil)
      expect(reference.open?).to eq(true)
      expect(reference.ticket_url).to eq("https://jira.dev.pardot.com/browse/PDT-98")

      stub_jira_ticket("PDT-98", resolved: true)
      @multipass.synchronize
      reference.reload
      expect(reference.open?).to eq(false)
    end

    it "removes existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      stub_github_pull_request(title: "Untitled")
      @multipass.synchronize
      expect(@multipass.reload.ticket_reference).to eq(nil)
    end

    it "does not create a JIRA ticket reference if the issue does not exist" do
      stub_jira_ticket("BREAD-1598", exists: false)
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      reference = @multipass.reload.ticket_reference
      expect(reference).to eq(nil)
    end

    it "closes the JIRA ticket if it is later deleted" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      reference = @multipass.reload.ticket_reference
      expect(reference.open?).to eq(true)

      stub_jira_ticket("BREAD-1598", exists: false)
      @multipass.synchronize
      expect(reference.reload.open?).to eq(false)
    end
  end

  describe "synchronizing github pull request" do
    it "updates the SHA to the merge commit after the PR has been merged" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598", merge_commit_sha: "abc123")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      expect(@multipass.reload.release_id).to eq("abc123")
    end
  end

  describe "synchronizing github statuses" do
    it "updates or creates commit status for the appropriate repository" do
      expect(RepositoryCommitStatus.count).to eq(0)

      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" }
      ])
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::SUCCESS)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::FAILURE, context: "ci/travis" }
      ])
      @multipass.synchronize
      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::FAILURE)
    end

    it "marks the testing status as success if all the required testing status are successful" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_pull_request_reviews

      expect(@multipass.testing?).to eq(false)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" }
      ])
      @multipass.synchronize
      expect(@multipass.reload.testing?).to eq(false)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/bazel" }
      ])
      @multipass.synchronize
      expect(@multipass.reload.testing?).to eq(true)
    end
  end

  describe "synchronizing peer reviewer" do
    it "does not set peer reviewer if the pull request has not been reviewed" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([])
      @repository_pull_request.synchronize

      expect(@multipass.reload.peer_reviewer).to eq(nil)
    end

    it "sets the peer reviewer to the first reviewer that approved the pull request" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: true },
        { github_login: "sr", approved: true }
      ])
      @repository_pull_request.synchronize

      expect(@multipass.reload.peer_reviewer).to eq("alindeman")
    end

    it "sets the peer reviewer to the first approval even if there are other negative reviews" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: false },
        { github_login: "sr", approved: true }
      ])
      @repository_pull_request.synchronize

      expect(@multipass.reload.peer_reviewer).to eq("sr")
    end

    it "removes the reviewer if they later rescind their review" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: true }
      ])
      @repository_pull_request.synchronize
      expect(@multipass.reload.peer_reviewer).to eq("alindeman")

      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: false }
      ])
      @repository_pull_request.synchronize
      expect(@multipass.reload.peer_reviewer).to eq(nil)
    end
  end
end
