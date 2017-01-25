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
    @pull_request = RepositoryPullRequest.new(@multipass)

    Changeling.config.repository_owners_review_required = [@pull_request.repository_full_name]
    Changeling.config.component_owners_review_enabled = [@pull_request.repository_full_name]

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

  it "returns the repository owners if the pull request has no changes" do
    expect(@pull_request.owners).to eq([])

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@pardot/boomtown\n@heroku/bread\n@heroku/tools\n",
    )
    stub_organization_teams("heroku", "bread": %w[alindeman sr], "tools": %w[ys])

    expect(@pull_request.reload.owners).to eq([%w[alindeman sr ys]])
  end

  it "returns the list of teams that owns components changed by this pull request" do
    expect(@pull_request.teams).to eq([])

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    stub_organization_teams("heroku", "ops": %w[alindeman sr])

    expect(@pull_request.reload.teams.size).to eq(1)
    team_1 = @pull_request.teams[0]
    expect(team_1.slug).to eq("heroku/ops")
    expect(team_1.url).to eq("#{Changeling.config.github_url}/orgs/heroku/teams/ops")
  end

  it "returns the OWNERS files relevant for the pull request" do
    expect(@pull_request.owners_files).to eq([])

    mysql = @repository.repository_owners_files.create!(
      path_name: "/cookbooks/pardot_mysql/#{Repository::OWNERS_FILENAME}",
      content: ""
    )
    expect(@pull_request.owners_files).to eq([])

    root = @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: ""
    )
    scripts = @repository.repository_owners_files.create!(
      path_name: "/scripts/#{Repository::OWNERS_FILENAME}",
      content: ""
    )
    lib = @repository.repository_owners_files.create!(
      path_name: "/lib/#{Repository::OWNERS_FILENAME}",
      content: ""
    )

    expect(@pull_request.owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/README",
      state: "added",
      patch: "+ Hello World"
    )
    expect(@pull_request.owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/nodes/dfw/pardot0-app1.json",
      state: "added",
      patch: "+ {}"
    )
    expect(@pull_request.owners_files).to eq([root])

    @multipass.pull_request_files.create!(
      filename: "/scripts/build",
      state: "modified",
      patch: "+ exit 1"
    )
    expect(@pull_request.owners_files).to eq([root, scripts])

    @multipass.pull_request_files.create!(
      filename: "/lib/foo.rb",
      state: "changed",
      patch: ""
    )
    expect(@pull_request.owners_files).to eq([root, scripts, lib])

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
    expect(@pull_request.owners_files).to eq([root, scripts, lib, mysql])
  end

  it "returns the owners of every component being changed" do
    team_bread = %w[alindeman sr]
    team_dba = %w[glen]
    team_ops = %w[alindeman sr glen]

    stub_organization_teams(
      "heroku",
      "bread": team_bread,
      "dba": team_dba,
      "ops": team_ops
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

    expect(@pull_request.reload.owners).to eq([])

    @repository.repository_owners_files.create!(
      path_name: "/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/ops"
    )
    expect(@pull_request.reload.owners).to eq([team_ops])

    @repository.repository_owners_files.create!(
      path_name: "/cookbooks/pardot_mysql/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/dba"
    )
    expect(@pull_request.reload.owners).to eq([team_ops, team_dba])

    @repository.repository_owners_files.create!(
      path_name: "/scripts/#{Repository::OWNERS_FILENAME}",
      content: "@heroku/bread"
    )
    expect(@pull_request.reload.owners).to eq([team_ops, team_dba, team_bread])
  end
end
