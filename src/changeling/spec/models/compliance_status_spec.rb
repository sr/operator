require "rails_helper"

describe ComplianceStatus, "pardot" do
  before(:each) do
    Changeling.config.pardot = true
    Changeling.config.repository_owners_review_required = []

    ticket = Ticket.create!(
      external_id: "1",
      summary: "fix everything",
      status: "Backlog",
      open: true,
      tracker: Ticket::TRACKER_JIRA
    )
    reference_url = format("https://%s/%s/pull/90",
      Changeling.config.github_hostname,
      PardotRepository::CHANGELING
    )
    @multipass = Fabricate(:multipass,
      testing: true,
      tests_state: RepositoryCommitStatus::SUCCESS,
      reference_url: reference_url
    )
    @multipass.create_ticket_reference!(ticket: ticket)
    @user = Fabricate(:user)

    stub_repository_owners(PardotRepository::CHANGELING, [])
  end

  def stub_repository_owners(repo, owners)
    owners = {
      type: "file",
      encoding: "base64",
      content: Base64.encode64(owners.join("\n"))
    }

    organization = repo.split("/")[0]

    bread = { id: 1, slug: "bread" }
    tools = { id: 2, slug: "tools" }
    teams = [bread, tools]
    bread_members = [{ login: "alindeman" }]
    tools_members = [{ login: "ys" }]

    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/orgs/#{organization}/teams")
      .to_return(body: JSON.dump(teams), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/teams/#{bread[:id]}/members")
      .to_return(body: JSON.dump(bread_members), headers: { "Content-Type" => "application/json" })
    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/teams/#{tools[:id]}/members")
      .to_return(body: JSON.dump(tools_members), headers: { "Content-Type" => "application/json" })

    stub_request(:get, "https://#{Changeling.config.github_hostname}/api/v3/repos/#{repo}/contents/OWNERS")
      .to_return(body: JSON.dump(owners), headers: { "Content-Type" => "application/json" })
  end

  it "can never be approved by a SRE" do
    @multipass.sre_approver = @user
    expect(@multipass.sre_approved?).to eq(false)
    expect(@multipass.user_is_sre_approver?(@user)).to eq(false)
  end

  it "requires a ticket reference to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.ticket_reference.destroy!
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Ticket reference is missing")
  end

  it "requires a reference to an open ticket to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.ticket_reference.ticket.update!(open: false, status: "Won't Fix")
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Referenced ticket is not open")
  end

  it "requires the builds to be successful" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(testing: true, tests_state: RepositoryCommitStatus::FAILURE)
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Automated tests failed")
  end

  it "requires the build to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(testing: false, tests_state: RepositoryCommitStatus::PENDING)
    expect(@multipass.reload.complete?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Awaiting automated tests results")
  end

  it "requires peer review to be complete" do
    expect(@multipass.complete?).to eq(true)
    expect(@multipass.peer_reviewed?).to eq(true)
    @multipass.update!(peer_reviewer: nil)
    expect(@multipass.reload.complete?).to eq(false)
    expect(@multipass.peer_reviewed?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Peer review is required")
  end

  it "requires peer review by one of the repository owners to be complete" do
    Changeling.config.repository_owners_review_required = [@multipass.repository_name]
    @multipass.peer_reviews.destroy_all

    stub_repository_owners(@multipass.repository_name, [])
    expect do
      @multipass.complete?
    end.to raise_error(Repository::OwnersError)

    stub_repository_owners(@multipass.repository_name, ["@alindeman"])
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    review = @multipass.peer_reviews.create!(
      reviewer_github_login: "alindeman",
      state: Clients::GitHub::REVIEW_CHANGES_REQUESTED
    )
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    review.update!(state: Clients::GitHub::REVIEW_APPROVED)
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)

    stub_repository_owners(@multipass.repository_name, ["@sr"])
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    @multipass.peer_reviews.create!(
      reviewer_github_login: "sr",
      state: Clients::GitHub::REVIEW_CHANGES_REQUESTED
    )
    stub_repository_owners(@multipass.repository_name, ["@alindeman", "@sr"])
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)

    stub_repository_owners(@multipass.repository_name, ["@heroku/bread"])
    @multipass.peer_reviews.destroy_all
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    @multipass.peer_reviews.create!(
      reviewer_github_login: "ys",
      state: Clients::GitHub::REVIEW_APPROVED
    )
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    @multipass.peer_reviews.create!(
      reviewer_github_login: "alindeman",
      state: Clients::GitHub::REVIEW_APPROVED
    )
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)
  end
end
