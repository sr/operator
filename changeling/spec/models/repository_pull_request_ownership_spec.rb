require "rails_helper"

RSpec.describe RepositoryPullRequest, "ownership" do
  before(:each) do
    Changeling.config.pardot = true

    @repository = GithubInstallation.current.repositories.create!(
      github_id: 1,
      github_owner_id: 1,
      owner: "heroku",
      name: "changeling"
    )
    reference_url = format("https://%s/%s/pull/90",
      Changeling.config.github_hostname,
      @repository.full_name
    )
    stub_organization_teams("heroku", {})
    @multipass = Fabricate(:multipass,
      testing: true,
      tests_state: RepositoryCommitStatus::SUCCESS,
      reference_url: reference_url,
      repository_id: @repository.id
    )
    @pull_request = RepositoryPullRequest.new(@multipass)
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

  def user(login)
    GithubUser.new(login)
  end

  it "returns the repository owners if the pull request has no changes" do
    create_team_memberships(bread: %w[alindeman sr], tools: %w[ys])
    expect(@pull_request.ownership_users).to eq([])

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@pardot/boomtown\n@heroku/bread\n@heroku/tools\n",
    )
    @pull_request.reload

    expect(@pull_request.ownership_users).to eq([
      [user("alindeman"), user("sr")],
      [user("ys")]
    ])
  end

  it "returns the list of teams that owns the file and directories being changed in this pull request" do
    expect(@pull_request.ownership_teams).to eq([])

    ownersfile = @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    create_team_memberships(ops: %w[alindeman sr])

    @pull_request.reload

    expect(@pull_request.ownership_teams.size).to eq(1)
    team_1 = @pull_request.ownership_teams[0]
    expect(team_1.slug).to eq("heroku/ops")
    expect(team_1.url).to eq("#{Changeling.config.github_url}/orgs/heroku/teams/ops")

    content = [
      "@heroku/ops",
      "@heroku/security dangerzone",
      "@heroku/bread build-*"
    ]
    ownersfile.update!(content: content.join("\n"))
    expect(@pull_request.ownership_teams.size).to eq(1)
    expect(@pull_request.ownership_teams[0].slug).to eq("heroku/ops")

    @multipass.pull_request_files.create!(
      filename: "/dangerzone",
      state: "added",
      patch: "+ LANAAAAA",
    )
    @pull_request.reload
    expect(@pull_request.ownership_teams.size).to eq(1)
    expect(@pull_request.ownership_teams[0].slug).to eq("heroku/security")

    @multipass.pull_request_files.create!(
      filename: "/build-everything",
      state: "added",
      patch: "+ exec true",
    )
    @pull_request.reload
    expect(@pull_request.ownership_teams.size).to eq(2)
    expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/security", "heroku/bread"])
  end

  it "returns the OWNERS files relevant for the pull request" do
    expect(@pull_request.ownership_owners_files).to eq([])

    mysql = @repository.repository_owners_files.create!(
      path_name: "/cookbooks/pardot_mysql/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/dba"
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([])

    root = @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    scripts = @repository.repository_owners_files.create!(
      path_name: "/scripts/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
    )
    lib = @repository.repository_owners_files.create!(
      path_name: "/lib/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
    )

    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/README",
      state: "added",
      patch: "+ Hello World"
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/nodes/dfw/pardot0-app1.json",
      state: "added",
      patch: "+ {}"
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/scripts/build",
      state: "modified",
      patch: "+ exit 1"
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts])

    @multipass.pull_request_files.create!(
      filename: "/lib/foo.rb",
      state: "changed",
      patch: ""
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts, lib])

    @multipass.pull_request_files.create!(
      filename: "/cookbooks/pardot_mysql/files/default/mysqld.conf",
      state: "removed",
      patch: ""
    )
    @multipass.pull_request_files.create!(
      filename: "/cookbooks/pardot_mysql/attributes/pardot.rb",
      state: "removed",
      patch: ""
    )
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts, lib, mysql])
  end

  it "returns the owners of every component being changed" do
    team_bread = %w[alindeman sr].map { |u| user(u) }
    team_dba = %w[glen].map { |u| user(u) }
    team_ops = %w[alindeman glen sr].map { |u| user(u) }

    create_team_memberships(
      "bread": team_bread.map(&:login),
      "dba": team_dba.map(&:login),
      "ops": team_ops.map(&:login)
    )

    @multipass.pull_request_files.create!(
      filename: "/README",
      state: "added",
      patch: "+ Hello World"
    )
    @multipass.pull_request_files.create!(
      filename: "/nodes/dfw/pardot0-app1.json",
      state: "added",
      patch: "+ {}"
    )
    @multipass.pull_request_files.create!(
      filename: "/cookbooks/pardot_mysql/files/default/mysqld.conf",
      state: "removed",
      patch: ""
    )
    @multipass.pull_request_files.create!(
      filename: "/scripts/build",
      state: "modified",
      patch: "+ exit 1"
    )

    expect(@pull_request.ownership_users).to eq([])

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    expect(@pull_request.reload.ownership_users).to eq([team_ops])

    @repository.repository_owners_files.create!(
      path_name: "/cookbooks/pardot_mysql/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/dba"
    )
    expect(@pull_request.reload.ownership_users).to eq([team_ops, team_dba])

    @repository.repository_owners_files.create!(
      path_name: "/scripts/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
    )
    expect(@pull_request.reload.ownership_users).to eq([team_ops, team_dba, team_bread])
  end
end
