require "rails_helper"

describe ComplianceStatus, "pardot" do
  before(:each) do
    Changeling.config.pardot = true
    Changeling.config.sre_team_slug = "heroku/sre"

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
    GithubTeamMembership.delete_all
    GithubInstallation.current.team_memberships.create!(
      github_team_id: 1,
      github_user_id: 1,
      team_slug: "heroku/bread",
      user_login: "sr"
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
      change_type: ChangeCategorization::STANDARD,
      testing: true,
      tests_state: RepositoryCommitStatus::SUCCESS,
      reference_url: reference_url,
      repository_id: @repository.id
    )
    @multipass.create_story_ticket_reference!(ticket: ticket)
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

  it "requires nothing if the change is an emergency" do
    @multipass.story_ticket_reference.destroy!
    @multipass.update!(peer_reviewer: nil)
    @multipass.update!(testing: true, tests_state: RepositoryCommitStatus::FAILURE)
    expect(@multipass.reload.complete?).to eq(false)

    @multipass.update(change_type: ChangeCategorization::EMERGENCY)
    expect(@multipass.reload.complete?).to eq(true)
  end

  it "requires a ticket reference to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.story_ticket_reference.destroy!
    expect(@multipass.reload.complete?).to eq(false)
    expect(@multipass.reload.pending?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Ticket reference is missing")

    html_description = @multipass.status_description_html
    expect(html_description).to include("<li>No ticket reference found")
  end

  it "requires a reference to an open ticket to be complete" do
    expect(@multipass.complete?).to eq(true)
    @multipass.story_ticket_reference.ticket.update!(open: false, status: "Won't Fix")
    expect(@multipass.reload.complete?).to eq(false)
    expect(@multipass.reload.pending?).to eq(false)

    description = @multipass.github_commit_status_description
    expect(description).to eq("Referenced ticket is not open")
  end

  it "does not require a ticket to be open if the pull request has been merged" do
    expect(@multipass.complete?).to eq(true)
    @multipass.update!(merged: true)
    @multipass.story_ticket_reference.ticket.update!(open: false, status: "Won't Fix")
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

  def create_team_memberships(teams)
    teams.each_with_index do |(team_name, members), team_id|
      members.each_with_index do |user_login, user_id|
        GithubInstallation.current.team_memberships.create!(
          github_team_id: team_id,
          github_user_id: user_id,
          team_slug: "heroku/#{team_name}",
          user_login: user_login
        )
      end
    end
  end

  it "requires peer review and approval by the component(s) owners" do
    @multipass.peer_reviews.destroy_all
    @multipass.pull_request_files.destroy_all
    @repository.repository_owners_files.delete_all
    GithubInstallation.current.team_memberships.delete_all

    create_team_memberships(
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

    expect(@multipass.peer_reviewed?).to eq(false)

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
    expect(@multipass.reload.peer_reviewed?).to eq(true)

    # One positive review per component is sufficient
    @multipass.peer_reviews.create!(
      reviewer_github_login: "alindeman",
      state: Clients::GitHub::REVIEW_CHANGES_REQUESTED,
    )
    expect(@multipass.reload.peer_reviewed?).to eq(true)
  end

  it "requires peer review by an SRE for #major changes" do
    @multipass.peer_reviews.destroy_all
    @multipass.pull_request_files.destroy_all
    @repository.repository_owners_files.delete_all
    GithubInstallation.current.team_memberships.delete_all

    create_team_memberships(
      "sre": %w[joel]
    )

    @multipass.change_type = ChangeCategorization::STANDARD
    @multipass.save!
    expect(@multipass.sre_approval_required?).to eq(false)
    expect(@multipass.sre_approved?).to eq(false)
    expect(@multipass.status_description_html).not_to match(/Review by a member of the.*sre.*team is required/)

    @multipass.change_type = ChangeCategorization::MAJOR
    @multipass.save!
    expect(@multipass.sre_approval_required?).to eq(true)
    expect(@multipass.sre_approved?).to eq(false)
    expect(@multipass.status_description_html).to match(/Review by a member of the.*sre.*team is required/)

    @multipass.peer_reviews.create!(
      reviewer_github_login: "joel",
      state: Clients::GitHub::REVIEW_APPROVED
    )
    expect(@multipass.sre_approved?).to eq(true)
    expect(@multipass.status_description_html).to match(/approved by a member of the.*sre.*team/)
  end
end
