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
    expect(description).to include("Peer review")
  end

  it "requires peer review by one of the repository owners to be complete" do
    Changeling.config.repository_owners_review_required = [@multipass.repository_name]
    @multipass.peer_reviews.destroy_all
    RepositoryOwnersFile.delete_all

    stub_organization_teams("heroku", {})

    expect do
      @multipass.complete?
    end.to raise_error(Repository::OwnersError)

    RepositoryOwnersFile.create!(
      repository_name: @multipass.repository_name,
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
end
