require "rails_helper"

describe ComplianceStatus, "pardot" do
  before(:each) do
    Changeling.config.pardot = true
    Changeling.config.repository_owners_review_required = []
    Changeling.config.component_owners_review_enabled = []

    ticket = Ticket.create!(
      external_id: "1",
      summary: "fix everything",
      status: "Backlog",
      open: true,
      tracker: Ticket::TRACKER_JIRA
    )
    @repository = GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: "heroku",
      name: "changeling",
    )
    reference_url = format("https://%s/%s/pull/90",
      Changeling.config.github_hostname,
      @repository.full_name
    )
    @multipass = Fabricate(:multipass,
      testing: true,
      tests_state: RepositoryCommitStatus::SUCCESS,
      reference_url: reference_url,
      repository_id: @repository.id
    )
    @multipass.create_ticket_reference!(ticket: ticket)
    @user = Fabricate(:user)

    stub_organization_teams("heroku", {})
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

  it "can never be approved by a SRE" do
    @multipass.sre_approver = @user
    expect(@multipass.sre_approved?).to eq(false)
    expect(@multipass.user_is_sre_approver?(@user)).to eq(false)
  end

  it "requires nothing if the change is an emergency" do
    @multipass.ticket_reference.destroy!
    @multipass.update!(peer_reviewer: nil)
    @multipass.update!(testing: true, tests_state: RepositoryCommitStatus::FAILURE)
    expect(@multipass.reload.complete?).to eq(false)

    @multipass.update(change_type: ChangeCategorization::EMERGENCY)
    expect(@multipass.reload.complete?).to eq(true)
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

  it "does not require a ticket to be open if the pull request has been merged" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(merged: true)
    @multipass.ticket_reference.ticket.update!(open: false, status: "Won't Fix")
    expect(@multipass.reload.complete?).to eq(true)
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
    expect(description).to include("Peer review")
  end

  it "requires peer review by repository owners to be complete" do
    Changeling.config.repository_owners_review_required = [@multipass.repository_name]
    @multipass.peer_reviews.destroy_all
    @multipass.pull_request_files.destroy_all
    @repository.repository_owners_files.delete_all

    stub_organization_teams("heroku", {})

    expect do
      @multipass.complete?
    end.to raise_error(Repository::OwnersError)

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread\n@heroku/tools\n",
    )

    stub_organization_teams("heroku", "bread": ["alindeman"])
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    review_1 = @multipass.peer_reviews.create!(
      reviewer_github_login: "alindeman",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)

    review_1.update!(state: Clients::GitHub::REVIEW_CHANGES_REQUESTED)
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    stub_organization_teams("heroku", "bread": ["alindeman", "sr"])
    review_2 = @multipass.peer_reviews.create!(
      reviewer_github_login: "sr",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)

    review_2.update!(state: Clients::GitHub::REVIEW_CHANGES_REQUESTED)
    expect(@multipass.peer_reviewed?).to eq(false)
    expect(@multipass.complete?).to eq(false)

    stub_organization_teams("heroku", "bread": ["alindeman", "sr"], "tools": ["ys"])
    @multipass.peer_reviews.create!(
      reviewer_github_login: "ys",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    expect(@multipass.peer_reviewed?).to eq(true)
    expect(@multipass.complete?).to eq(true)
  end

  it "requires peer review and approval by the component(s) owners" do
    Changeling.config.repository_owners_review_required = [@multipass.repository_name]
    Changeling.config.component_owners_review_enabled = [@multipass.repository_name]
    @multipass.peer_reviews.destroy_all
    @multipass.pull_request_files.destroy_all
    @repository.repository_owners_files.delete_all

    stub_organization_teams(
      "heroku",
      "ops": %w[alindeman sr glenn],
      "bread": %w[alindeman sr],
      "dba": %w[glenn]
    )

    @multipass.pull_request_files.create!(
      filename: "README",
      state: "added",
      patch: "+ Hello World"
    )
    @multipass.pull_request_files.create!(
      filename: "/cookbooks/pardot_mysql/README",
      state: "added",
      patch: "+ test"
    )
    @multipass.pull_request_files.create!(
      filename: "/scripts/build",
      state: "modified",
      patch: "+ exit 1"
    )

    expect do
      @multipass.peer_reviewed?
    end.to raise_error(Repository::OwnersError)

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    @repository.repository_owners_files.create!(
      path_name: "/cookbooks/pardot_mysql/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/dba"
    )
    @repository.repository_owners_files.create!(
      path_name: "/scripts/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
    )

    expect(@multipass.peer_reviewed?).to eq(false)
    @multipass.peer_reviews.create!(
      reviewer_github_login: "sr",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    expect(@multipass.peer_reviewed?).to eq(false)

    expect(@multipass.peer_reviewed?).to eq(false)
    @multipass.peer_reviews.create!(
      reviewer_github_login: "glenn",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    expect(@multipass.peer_reviewed?).to eq(true)

    # One positive review per component is sufficient
    @multipass.peer_reviews.create!(
      reviewer_github_login: "alindeman",
      state: Clients::GitHub::REVIEW_CHANGES_REQUESTED,
    )
    expect(@multipass.peer_reviewed?).to eq(true)
  end
end
