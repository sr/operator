require "rails_helper"

RSpec.describe RepositoryPullRequest do
  before(:each) do
    Changeling.config.pardot = true
    @repository = GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: "heroku",
      name: "changeling"
    )
    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/boomtown\n"
    )
    reference_url = format("https://%s/%s/pull/32",
      Changeling.config.github_hostname,
      @repository.full_name
    )
    stub_organization_teams("heroku", {})
    @multipass = Fabricate(:multipass,
      change_type: ChangeCategorization::STANDARD,
      requester: "user",
      peer_reviewer: "reviewer",
      reference_url: reference_url,
      release_id: "deadbeef",
      testing: nil,
      repository_id: @repository.id
    )
    @repository_pull_request = RepositoryPullRequest.new(@multipass)
  end

  def stub_jira_ticket(external_id, exists: true, resolved: false)
    if exists
      issue = decoded_fixture_data("jira/issue")
      issue["key"] = external_id
      issue["fields"]["resolution"] = nil unless resolved
      issue["self"] = "rest/api/2/issue/#{external_id}"
      stub_request(:get, "https://sa_changeling:fakefakefake@jira.dev.pardot.com/rest/api/2/issue/#{external_id}")
        .to_return(body: JSON.dump(issue), headers: { "Content-Type" => "application/json" })
    else
      stub_request(:get, "https://sa_changeling:fakefakefake@jira.dev.pardot.com/rest/api/2/issue/#{external_id}")
        .to_return(body: JSON.dump({}), status: 404, headers: { "Content-Type" => "application/json" })
    end
  end

  def stub_jira_ticket_creation(external_id)
    issue = decoded_fixture_data("jira/issue")
    issue["key"] = external_id
    issue["fields"]["resolution"] = nil
    issue["self"] = "/rest/iss"

    stub_request(:post, "https://#{Changeling.config.jira_username}:#{Changeling.config.jira_password}@#{URI(Changeling.config.jira_url).host}/rest/api/2/issue")
      .to_return(status: 200, body: JSON.dump(issue))

    stub_jira_ticket(external_id)

    stub_request(:put, "https://#{Changeling.config.jira_username}:#{Changeling.config.jira_password}@#{URI(Changeling.config.jira_url).host}/rest/api/2/issue/#{external_id}")
      .to_return(status: 200, body: JSON.dump(issue))
  end

  # rubocop:disable Metrics/ParameterLists
  def stub_github_pull_request(title: nil, merge_commit_sha: nil, merged_at: nil, base_ref: "master", files: [], body: "")
    pull_request = decoded_fixture_data("github/pull_request")
    pull_request["head"]["sha"] = @multipass.release_id
    pull_request["base"]["ref"] = base_ref
    pull_request["body"] = body
    pull_request["title"] = title if title
    if merge_commit_sha
      pull_request["merged"] = true
      pull_request["merge_commit_sha"] = merge_commit_sha
      if merged_at
        pull_request["merged_at"] = merged_at
      end
    end

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/pulls/#{@multipass.pull_request_number}")
      .to_return(body: JSON.dump(pull_request), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/pulls/#{@multipass.pull_request_number}/files")
      .to_return(body: JSON.dump(files), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_commit(sha:, email: "user@example.com")
    commit = {
      commit: {
        author: {
          email: email,
          date: Time.current
        }
      }
    }
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{@repository.full_name}/commits/#{sha}")
      .to_return(body: JSON.dump(commit), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_commit_status(statuses: [])
    combined_status = {
      repository: {
        id: 1
      },
      sha: @multipass.release_id,
      statuses: statuses
    }

    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{@repository.full_name}/commits/#{@multipass.release_id}/status")
      .to_return(body: JSON.dump(combined_status), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_pull_request_comments(comments = [])
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{@repository.full_name}/issues/#{@multipass.pull_request_number}/comments")
      .to_return(body: JSON.dump(comments), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_pull_request_comment_creation
    stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/issues/#{@repository_pull_request.number}/comments")
      .to_return(status: 201, body: JSON.dump(id: 1), headers: { "Content-Type": "application/json" })
  end

  def stub_github_pull_request_labels(labels = [])
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{@repository.full_name}/issues/#{@multipass.pull_request_number}/labels")
      .to_return(body: JSON.dump(labels), headers: { "Content-Type" => "application/json" })

    stub_request(:post, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{@repository.full_name}/issues/#{@multipass.pull_request_number}/labels")
      .to_return(status: 201)
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

    stub_request(:get, "https://#{Changeling.config.github_hostname}/#{@repository.full_name}/pull/#{@multipass.pull_request_number}")
      .to_return(body: body, headers: { "Content-Type" => "text/html" })
  end

  def stub_organization_teams(organization, teams)
    teams_data = []
    teams.keys.each_with_index do |slug, index|
      teams_data << { id: index, slug: slug }
    end

    stub_request(:get, "#{Changeling.config.github_api_endpoint}/orgs/#{organization}/teams")
      .to_return(body: JSON.dump(teams_data), headers: { "Content-Type" => "application/json" })

    teams.each_with_index do |(_, members), index|
      data = members.map { |member| { login: member } }

      stub_request(:get, "#{Changeling.config.github_api_endpoint}/teams/#{index}/members")
        .to_return(body: JSON.dump(data), headers: { "Content-Type" => "application/json" })
    end
  end

  describe "synchronizing ticket references" do
    it "creates a ticket references for JIRA tickets" do
      expect(@multipass.referenced_ticket).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

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
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.story_ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "    BREAD-1598: hello")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.story_ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.story_ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      @multipass.story_ticket_reference.destroy!
      expect(@multipass.reload.referenced_ticket).to eq(nil)
      stub_github_pull_request(title: "[BREAD-1598] - hello")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)
    end

    it "updates existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      stub_jira_ticket("PDT-98")
      stub_github_pull_request(title: "PDT-98 Fix everything")
      @repository_pull_request.synchronize(create_github_status: false)

      ticket = @multipass.reload.referenced_ticket
      expect(ticket).to_not eq(nil)
      expect(ticket.open?).to eq(true)
      expect(ticket.url).to eq("https://jira.dev.pardot.com/browse/PDT-98")

      stub_jira_ticket("PDT-98", resolved: true)
      @repository_pull_request.synchronize(create_github_status: false)
      ticket.reload
      expect(ticket.open?).to eq(false)
    end

    it "removes existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to_not eq(nil)

      stub_github_pull_request(title: "Untitled")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to eq(nil)
    end

    it "does not create a JIRA ticket reference if the issue does not exist" do
      stub_jira_ticket("BREAD-1598", exists: false)
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

      ticket = @multipass.reload.referenced_ticket
      expect(ticket).to eq(nil)
    end

    it "closes the JIRA ticket if it is later deleted" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

      ticket = @multipass.reload.referenced_ticket
      expect(ticket.open?).to eq(true)

      stub_jira_ticket("BREAD-1598", exists: false)
      @repository_pull_request.synchronize(create_github_status: false)
      expect(ticket.reload.open?).to eq(false)
    end

    it "handles GUS Work ticket references" do
      stub_github_pull_request(title: "W-3343901 Draw the rest of the owl")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

      expect(@multipass.reload.referenced_ticket).to_not eq(nil)
      ticket = @multipass.reload.referenced_ticket
      expect(ticket.open?).to eq(true)
      expect(ticket.external_id).to eq("W-3343901")
      expect(ticket.summary).to eq("Draw the rest of the owl")
      expect(ticket.tracker).to eq(Ticket::TRACKER_GUS)

      stub_github_pull_request(title: "W-3343901")
      @repository_pull_request.synchronize(create_github_status: false)
      ticket = @multipass.reload.referenced_ticket
      expect(ticket.summary).to eq("")

      stub_github_pull_request(title: "boomtown")
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.referenced_ticket).to eq(nil)
    end
  end

  describe "synchronizing github pull request" do
    it "sets the merge commit SHA if present" do
      stub_jira_ticket("BREAD-1598")
      stub_jira_ticket_creation("BREAD-emergency")
      stub_github_pull_request(title: "BREAD-1598", merge_commit_sha: "abc123")
      stub_github_commit(sha: "abc123")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      original_release_id = @multipass.release_id
      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload

      expect(@multipass.release_id).to eq(original_release_id)
      expect(@multipass.merge_commit_sha).to eq("abc123")
    end

    it "sets the merge datetime if present" do
      stub_jira_ticket("BREAD-1598")
      stub_jira_ticket_creation("BREAD-emergency")
      stub_github_pull_request(title: "BREAD-1598", merge_commit_sha: "abc123", merged_at: "2011-01-26T19:01:12Z")
      stub_github_commit(sha: "abc123")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      original_release_id = @multipass.release_id
      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload

      expect(@multipass.release_id).to eq(original_release_id)
      expect(@multipass.merged_at).to eq("2011-01-26T19:01:12Z")
    end

    it "synchronizes changed files" do
      stub_jira_ticket("BREAD-1598")
      stub_jira_ticket_creation("BREAD-emergency")
      stub_github_pull_request(
        title: "BREAD-1598",
        merge_commit_sha: "abc123",
        files: [
          { status: "added", filename: "boomtown", patch: "+ hi" }
        ]
      )
      stub_github_commit(sha: "abc123")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      expect(@multipass.changed_files).to eq([])
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.changed_files).to eq([Pathname("/boomtown")])

      stub_github_pull_request(
        title: "BREAD-1598",
        merge_commit_sha: "abc123",
        files: [
          { status: "added", filename: "README", patch: "+ rtfm" },
          { status: "removed", filename: "config", patch: "" }
        ]
      )
      @repository_pull_request.synchronize(create_github_status: false)
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
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::SUCCESS)
      expect(status.repository_id).to eq(@repository.id)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::FAILURE, context: "ci/travis" }
      ])
      @repository_pull_request.synchronize(create_github_status: false)
      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::FAILURE)
    end

    it "marks the testing status as success if all the required testing status are successful" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_pull_request_reviews
      stub_github_commit_status(statuses: [])
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      config = Bread::RepositoryConfig.new(
        required_testing_statuses: ["ci/travis", "ci/bazel"]
      )
      @repository.update!(config_file_content: config.to_json)

      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.testing).to eq(false)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::PENDING)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::PENDING, context: "ci/bazel" }
      ])
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.testing).to eq(true)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::PENDING)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::FAILURE, context: "ci/bazel" }
      ])
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.testing).to eq(true)
      expect(@multipass.tests_state).to eq(RepositoryCommitStatus::FAILURE)

      stub_github_commit_status(statuses: [
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/travis" },
        { state: RepositoryCommitStatus::SUCCESS, context: "ci/bazel" }
      ])
      @repository_pull_request.synchronize(create_github_status: false)
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
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

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
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

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
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)

      expect(@multipass.reload.peer_reviewer).to eq("sr")
    end

    it "removes the reviewer if they later rescind their review" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: true }
      ])
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.peer_reviewer).to eq("alindeman")

      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: false }
      ])
      @repository_pull_request.synchronize(create_github_status: false)
      expect(@multipass.reload.peer_reviewer).to eq(nil)
    end

    it "synchronizes peer reviewers" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status
      stub_github_pull_request_reviews([])
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation
      expect(@multipass.reload.peer_reviews).to eq([])

      stub_github_pull_request_reviews([
        { github_login: "alindeman", approved: true },
        { github_login: "sr", approved: false }
      ])
      @repository_pull_request.synchronize(create_github_status: false)

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
      @repository_pull_request.synchronize(create_github_status: false)
      review = @multipass.reload.peer_reviews.where(reviewer_github_login: "sr").first!
      expect(review.state).to eq(Clients::GitHub::REVIEW_APPROVED)
    end
  end

  describe "setting change type" do
    it "sets the change type to standard by default" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload
      expect(@multipass.change_type).to eq(ChangeCategorization::STANDARD)
    end

    it "sets the change type to major if the pull request body specifies #major" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598", body: "Dangerzone! #major")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload
      expect(@multipass.change_type).to eq(ChangeCategorization::MAJOR)
    end

    it "sets the change type to major if a pull request comment specifies #major" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments([
        {
          body: "I think we need extra review on this one #major",
          user: { login: "alindeman" }
        }
      ])
      stub_github_commit(sha: "abc123")
      stub_github_pull_request_labels
      stub_github_pull_request_comment_creation

      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload
      expect(@multipass.change_type).to eq(ChangeCategorization::MAJOR)
    end

    it "detects emergency merges" do
      @repository.update!(compliance_enabled: true)
      @repository.repository_owners_files
        .find_by!(path_name: "/#{Repository::OWNERS_FILENAME}")
        .update!(content: "@heroku/bread")
      stub_organization_teams("heroku", "bread": %w[ys])
      stub_jira_ticket("BREAD-1598")
      stub_jira_ticket_creation("BREAD-emergency")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit(sha: "abc123")
      stub_github_commit_status
      stub_github_pull_request_reviews
      stub_github_pull_request_comments
      stub_github_pull_request_labels
      stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/issues/#{@repository_pull_request.number}/comments")
        .to_return(status: 201, headers: { "Content-Type": "application/json" }, body: JSON.dump(id: 1))

      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload
      expect(@multipass.change_type).to_not eq(ChangeCategorization::EMERGENCY)
      expect(@multipass.complete?).to eq(false)

      stub_github_pull_request(title: "BREAD-1598", merge_commit_sha: "abc123")
      expect(@multipass.emergency_ticket_reference).to eq(nil)
      @repository_pull_request.synchronize(create_github_status: false)
      @multipass.reload
      expect(@multipass.emergency_ticket_reference).to_not eq(nil)
      expect(@multipass.emergency_ticket_reference.ticket_type).to eq(TicketReference::TICKET_TYPE_EMERGENCY)
      expect(@multipass.emergency_ticket_reference.ticket.external_id).to eq("BREAD-emergency")
      expect(@multipass.emergency_ticket_reference.ticket.open?).to eq(true)

      expect(@multipass.change_type).to eq(ChangeCategorization::EMERGENCY)

      stub_jira_ticket("BREAD-emergency", resolved: true)
      @repository_pull_request.reload.synchronize(create_github_status: false)
      expect(@multipass.emergency_ticket_reference.ticket.reload.open?).to eq(false)
    end
  end

  it "updates the github comment describing the status of the PR" do
    @repository.update!(compliance_enabled: true)
    @repository.repository_owners_files
      .find_by!(path_name: "/#{Repository::OWNERS_FILENAME}")
      .update!(content: "@heroku/ops")
    stub_organization_teams("heroku", "ops": %w[alindeman sr])
    stub_jira_ticket("BREAD-1598")
    stub_github_pull_request(title: "BREAD-1598")
    stub_github_commit_status
    stub_github_pull_request_reviews
    stub_github_pull_request_comments
    stub_github_pull_request_labels

    stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/statuses/deadbeef")

    request = stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/issues/#{@repository_pull_request.number}/comments")
      .to_return(status: 201, body: JSON.dump(id: 1), headers: { "Content-Type": "application/json" })

    @multipass.synchronize

    expect(request).to have_been_made.once
  end

  it "does not create a github comment if the PR does not affect the default branch" do
    @repository.update!(compliance_enabled: true)
    @repository.repository_owners_files
      .find_by!(path_name: "/#{Repository::OWNERS_FILENAME}")
      .update!(content: "@heroku/ops")
    stub_organization_teams("heroku", "ops": %w[alindeman sr])
    stub_jira_ticket("BREAD-1598")
    stub_github_pull_request(title: "BREAD-1598", base_ref: "feature-branch")
    stub_github_commit_status
    stub_github_pull_request_reviews
    stub_github_pull_request_comments
    stub_github_pull_request_labels

    status_req = stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/statuses/deadbeef")

    comment_req = stub_request(:post, "#{Changeling.config.github_api_endpoint}/repos/#{@repository.full_name}/issues/#{@repository_pull_request.number}/comments")

    @multipass.synchronize

    expect(status_req).not_to have_been_made
    expect(comment_req).not_to have_been_made
  end
end
