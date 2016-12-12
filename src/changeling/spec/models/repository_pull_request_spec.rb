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

  def stub_jira_ticket(external_id, resolved: false)
    issue = decoded_fixture_data("jira/issue")
    issue["key"] = external_id
    issue["fields"]["resolution"] = nil unless resolved
    stub_request(:get, "https://sa_changeling:fakefakefake@jira.dev.pardot.com/rest/api/2/issue/#{external_id}")
      .to_return(body: JSON.dump(issue), headers: { "Content-Type" => "application/json" })
  end

  def stub_github_pull_request(title: nil)
    pull_request = decoded_fixture_data("github/pull_request")
    pull_request["head"]["sha"] = @multipass.release_id
    pull_request["title"] = title if title
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

  describe "synchronizing ticket references" do
    it "creates a ticket references for JIRA tickets" do
      expect(@multipass.ticket_reference).to eq(nil)

      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      @repository_pull_request.synchronize

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
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "BREAD-1598 - hello")
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      @multipass.ticket_reference.destroy!
      expect(@multipass.reload.ticket_reference).to eq(nil)
      stub_github_pull_request(title: "[BREAD-1598] - hello")
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)
    end

    it "updates existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598 Enforce traceability of PR back to ticket")
      stub_github_commit_status
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      stub_jira_ticket("PDT-98")
      stub_github_pull_request(title: "PDT-98 Fix everything")
      @repository_pull_request.synchronize

      reference = @multipass.reload.ticket_reference
      expect(reference).to_not eq(nil)
      expect(reference.open?).to eq(true)
      expect(reference.ticket_url).to eq("https://jira.dev.pardot.com/browse/PDT-98")

      stub_jira_ticket("PDT-98", resolved: true)
      @repository_pull_request.synchronize
      reference.reload
      expect(reference.open?).to eq(false)
    end

    it "removes existing JIRA ticket reference" do
      stub_jira_ticket("BREAD-1598")
      stub_github_pull_request(title: "BREAD-1598")
      stub_github_commit_status
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to_not eq(nil)

      stub_github_pull_request(title: "Untitled")
      @repository_pull_request.synchronize
      expect(@multipass.reload.ticket_reference).to eq(nil)
    end
  end

  describe "synchronizing github statuses" do
    it "updates or creates commit status for the appropriate repository" do
      expect(RepositoryCommitStatus.count).to eq(0)

      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request
      stub_github_commit_status(statuses: [
        {state: RepositoryCommitStatus::SUCCESS, context: "ci/travis"}
      ])
      @repository_pull_request.synchronize
      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::SUCCESS)

      stub_github_commit_status(statuses: [
        {state: RepositoryCommitStatus::FAILURE, context: "ci/travis"}
      ])
      @repository_pull_request.synchronize
      expect(RepositoryCommitStatus.count).to eq(1)
      status = RepositoryCommitStatus.first!
      expect(status.state).to eq(RepositoryCommitStatus::FAILURE)
    end

    it "marks the testing status as success if all the required testing status are successful" do
      stub_jira_ticket("BREAD-1234")
      stub_github_pull_request

      expect(@multipass.testing?).to eq(false)

      stub_github_commit_status(statuses: [
        {state: RepositoryCommitStatus::SUCCESS, context: "ci/travis"}
      ])
      @repository_pull_request.synchronize
      expect(@multipass.reload.testing?).to eq(false)

      stub_github_commit_status(statuses: [
        {state: RepositoryCommitStatus::SUCCESS, context: "ci/travis"},
        {state: RepositoryCommitStatus::SUCCESS, context: "ci/bazel"}
      ])
      @repository_pull_request.synchronize
      expect(@multipass.reload.testing?).to eq(true)
    end
  end
end
