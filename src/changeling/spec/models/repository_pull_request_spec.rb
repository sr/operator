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
    @repository = GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: "heroku",
      name: "changeling"
    )
    @repository_pull_request = RepositoryPullRequest.new(@multipass)
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

  def stub_github_pull_request(title: nil, merge_commit_sha: nil, files: [])
    pull_request = decoded_fixture_data("github/pull_request")
    pull_request["head"]["sha"] = @multipass.release_id
    pull_request["title"] = title if title
    if merge_commit_sha
      pull_request["merged"] = true
      pull_request["merge_commit_sha"] = merge_commit_sha
    end

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{PardotRepository::CHANGELING}/pulls/#{@multipass.pull_request_number}")
      .to_return(body: JSON.dump(pull_request), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{PardotRepository::CHANGELING}/pulls/#{@multipass.pull_request_number}/files")
      .to_return(body: JSON.dump(files), headers: { "Content-Type" => "application/json" })
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
      expect(@multipass.referenced_ticket).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      expect(@multipass.reload.referenced_ticket).to_not eq(nil)
      ticket = @multipass.reload.referenced_ticket
      expect(ticket.open?).to eq(true)
      expect(ticket.url).to eq("https://jira.dev.pardot.com/browse/BREAD-1598")
    end

    it "detects most common ticket ID - title separators" do
      expect(@multipass.referenced_ticket).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598: hello")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "    BREAD-1598: hello")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "[BREAD-1598] - hello")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)
    end

    it "updates existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      stub_jira_ticket("PDT-98")
      stub_github_pull_request(title: "PDT-98 Fix everything")
      @multipass.synchronize

      ticket = @multipass.reload.referenced_ticket
      expect(ticket).to_not eq(nil)
      expect(ticket.open?).to eq(true)
      expect(ticket.url).to eq("https://jira.dev.pardot.com/browse/PDT-98")

      stub_jira_ticket("PDT-98", resolved: true)
      @multipass.synchronize
      ticket.reload
      expect(ticket.open?).to eq(false)
    end

    it "removes existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      stub_github_pull_request(title: "Untitled")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to eq(nil)
    end

    it "does not create a JIRA ticket reference if the issue does not exist" do
      stub_jira_ticket("BREAD-1598", exists: false)
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      ticket = @multipass.reload.referenced_ticket
      expect(ticket).to eq(nil)
    end

    it "closes the JIRA ticket if it is later deleted" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      ticket = @multipass.reload.referenced_ticket
      expect(ticket.open?).to eq(true)

      stub_jira_ticket("BREAD-1598", exists: false)
      @multipass.synchronize
      expect(ticket.reload.open?).to eq(false)
    end

    it "handles GUS Work ticket references" do
      stub_github_pull_request(title: "W-3343901 Draw the rest of the owl")
      stub_github_commit_status
      stub_github_pull_request_reviews
      @multipass.synchronize

      expect(@multipass.reload.referenced_ticket).to_not eq(nil)
      ticket = @multipass.reload.referenced_ticket
      expect(ticket.open?).to eq(true)
      expect(ticket.external_id).to eq("W-3343901")
      expect(ticket.summary).to eq("Draw the rest of the owl")
      expect(ticket.tracker).to eq(Ticket::TRACKER_GUS)

      stub_github_pull_request(title: "W-3343901")
      @multipass.synchronize
      ticket = @multipass.reload.referenced_ticket
      expect(ticket.summary).to eq("")

      stub_github_pull_request(title: "boomtown")
      @multipass.synchronize
      expect(@multipass.reload.referenced_ticket).to eq(nil)
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

    it "synchronizes changed files" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(
        title: "BREAD-1598",
        merge_commit_sha: "abc123",
        files: [
          { status: "added", filename: "boomtown", patch: "+ hi" }
        ]
      )
      stub_github_commit_status
      stub_github_pull_request_reviews

      expect(@multipass.changed_files).to eq([])
      @multipass.synchronize
      expect(@multipass.changed_files).to eq([Pathname("/boomtown")])

      stub_github_pull_request(
        title: "BREAD-1598",
        merge_commit_sha: "abc123",
        files: [
          { status: "added", filename: "README", patch: "+ rtfm" },
          { status: "removed", filename: "config", patch: "" }
        ]
      )
      @multipass.synchronize
      expect(@multipass.changed_files).to eq([Pathname("/README"), Pathname("/config")])
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
      expect(status.repository_id).to eq(@repository.id)

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
      stub_github_commit_status(statuses: [])

      @multipass.synchronize
      expect(@multipass.testing).to eq(false)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::PENDING)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::PENDING, context: "ci/bazel" }
      ])
      @multipass.synchronize
      expect(@multipass.testing).to eq(true)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::PENDING)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::FAILURE, context: "ci/bazel" }
      ])
      @multipass.synchronize
      expect(@multipass.testing).to eq(true)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::FAILURE)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/bazel" }
      ])
      @multipass.synchronize
      expect(@multipass.testing).to eq(true)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::SUCCESS)
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

  it "synchronizes peer reviewers" do
    stub_jira_ticket("BREAD-1234")
    stub_github_pull_request
    stub_github_commit_status
    stub_github_pull_request_reviews([])
    expect(@multipass.reload.peer_reviews).to eq([])

    stub_github_pull_request_reviews([
      { github_login: "alindeman", approved: true },
      { github_login: "sr", approved: false }
    ])
    @repository_pull_request.synchronize

    expect(@multipass.reload.peer_reviews.size).to eq(2)

    review_1 = @multipass.peer_reviews[0]
    expect(review_1.reviewer_github_login).to eq("alindeman")
    expect(review_1.state).to eq(Clients::GitHub::REVIEW_APPROVED)

    review_2 = @multipass.peer_reviews[1]
    expect(review_2.reviewer_github_login).to eq("sr")
    expect(review_2.state).to eq(Clients::GitHub::REVIEW_CHANGES_REQUESTED)

    stub_github_pull_request_reviews([
      { github_login: "alindeman", approved: true },
      { github_login: "sr", approved: true }
    ])
    @repository_pull_request.synchronize
    review = @multipass.reload.peer_reviews.where(reviewer_github_login: "sr").first!
    expect(review.state).to eq(Clients::GitHub::REVIEW_APPROVED)
  end
end
