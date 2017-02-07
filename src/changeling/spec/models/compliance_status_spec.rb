require "rails_helper"

describe ComplianceStatus, "pardot" do
  before(:each) do
    Changeling.config.pardot = true

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
    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
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
    @multipass.peer_reviews.create!(
      reviewer_github_login: "sr",
      state: Clients::GitHub::REVIEW_APPROVED,
    )
    @user = Fabricate(:user)

    stub_organization_teams("heroku", bread: %w[sr])
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
    expect(@multipass.reload.pending?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Ticket reference is missing")
  end

  it "requires a reference to an open ticket to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.ticket_reference.ticket.update!(open: false, status: "Won't Fix")
    expect(@multipass.reload.complete?).to eq(false)
    expect(@multipass.reload.pending?).to eq(false)

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
    expect(@multipass.reload.pending?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Automated tests failed")
  end

  it "requires the build to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(testing: false, tests_state: RepositoryCommitStatus::PENDING)
    expect(@multipass.reload.complete?).to eq(false)
    expect(@multipass.reload.pending?).to eq(true)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Awaiting automated tests results")
  end

  it "requires peer review and approval by the component(s) owners" do
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
      state: "changed",
      patch: ""
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

    # TODO(sr) Memoization is the worst
    @multipass.instance_variable_set(:@repository_pull_request, nil)

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
