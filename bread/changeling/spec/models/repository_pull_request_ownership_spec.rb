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

  def create_pull_request_file(path)
    @multipass.pull_request_files.create!(filename: path, state: "modified", patch: "+ hi")
  end

  def create_owners_file(directory, lines = [])
    @repository.repository_owners_files.create!(
      path_name: File.join(directory, Repository::OWNERS_FILENAME),
      content: lines.map { |line| "@#{line}" }.join("\n")
    )
  end

  it "returns the OWNERS files relevant for the pull request" do
    expect(@pull_request.ownership_owners_files).to eq([])
    expect(@pull_request.reload.ownership_owners_files).to eq([])

    root = create_owners_file("/", ["heroku/ops"])
    scripts = create_owners_file("/scripts", ["heroku/bread"])
    lib = create_owners_file("/lib", ["heroku/bread"])
    mysql = create_owners_file("/cookbooks/pardot_mysql", ["heroku/dba"])

    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    create_pull_request_file("/README")
    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    create_pull_request_file("/nodes/dfw/pardot0-app1.json")
    expect(@pull_request.reload.ownership_owners_files).to eq([root])

    create_pull_request_file("/scripts/build")
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts])

    create_pull_request_file("/lib/foo.rb")
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts, lib])

    create_pull_request_file("/cookbooks/pardot_mysql/files/default/mysqld.conf")
    create_pull_request_file("/cookbooks/pardot_mysql/attributes/pardot.rb")
    expect(@pull_request.reload.ownership_owners_files).to eq([root, scripts, lib, mysql])
  end

  describe "ownership_teams" do
    before(:all) do
      @team_bread = %w[alindeman sr].map { |u| user(u) }
      @team_dba = %w[glen].map { |u| user(u) }
      @team_ops = %w[alindeman glen sr].map { |u| user(u) }

      GithubTeamMembership.delete_all

      create_team_memberships(
        "bread": @team_bread.map(&:login),
        "dba": @team_dba.map(&:login),
        "ops": @team_ops.map(&:login)
      )
    end

    it "returns an empty array if there is no OWNERS file" do
      expect(@pull_request.repository_owners_files.size).to eq(0)
      expect(@pull_request.ownership_teams).to eq([])
    end

    it "returns the repository owners when there are no change" do
      teams = ["heroku/bread", "heroku/ops"]
      create_owners_file("/", teams)
      expect(@multipass.changed_files.size).to eq(0)
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(teams)
    end

    it "returns subtree owners" do
      teams = ["heroku/dba"]
      create_owners_file("/cookbooks/pardot_mysql", teams)
      create_pull_request_file("/cookbooks/pardot_mysql/files/default/mysqld.conf")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(teams)
    end

    it "returns file owners" do
      create_owners_file("/", ["heroku/ops", "heroku/bread build.sh"])
      create_pull_request_file("/build.sh")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/bread"])
      create_pull_request_file("/REAMDE.md")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/ops", "heroku/bread"])
    end

    it "returns files owners for matching globs" do
      create_owners_file("/script", ["heroku/bread *.sh"])
      create_pull_request_file("/script/build")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array([])
      create_pull_request_file("/script/build.sh")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/bread"])
    end

    it "returns repository, subtree, and file owners" do
      create_owners_file("/", ["heroku/ops"])
      create_owners_file("/script", ["heroku/bread"])
      create_owners_file("/roles", ["heroku/dba pardot_mysql*"])

      create_pull_request_file("/script/build")
      create_pull_request_file("/roles/pardot_mysql_dfw.rb")

      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/bread", "heroku/dba"])
      create_pull_request_file("/README")
      expect(@pull_request.ownership_teams.map(&:slug)).to match_array(["heroku/bread", "heroku/dba", "heroku/ops"])
    end
  end

  describe "ownership_users" do
    before(:all) do
      @team_bread = %w[alindeman sr].map { |u| user(u) }
      @team_developers = %w[smiley].map { |u| user(u) }
      @team_ops = %w[alindeman sr].map { |u| user(u) }

      GithubTeamMembership.delete_all

      create_team_memberships(
        "bread": @team_bread.map(&:login),
        "developers": @team_developers.map(&:login),
        "ops": @team_ops.map(&:login)
      )
    end

    it "returns one array of users per owned directory" do
      create_owners_file("/pardot", ["heroku/developers", "heroku/bread"])
      create_pull_request_file("/pardot/README")
      expect(@pull_request.reload.ownership_users).to eq([[user("alindeman"), user("sr"), user("smiley")]])

      create_owners_file("/chef", ["heroku/ops"])
      create_pull_request_file("/chef/README")
      expect(@pull_request.reload.ownership_users).to eq([[user("alindeman"), user("sr"), user("smiley")], [user("alindeman"), user("sr")]])
    end

    it "returns one array of users per owned file" do
      create_owners_file("/", ["heroku/developers index.php", "heroku/bread build.sh"])
      expect(@pull_request.reload.ownership_users).to eq([])

      create_pull_request_file("/index.php")
      expect(@pull_request.reload.ownership_users).to eq([[user("smiley")]])

      create_pull_request_file("/build.sh")
      expect(@pull_request.reload.ownership_users).to eq([[user("smiley")], [user("alindeman"), user("sr")]])
    end

    it "ignores empty OWNERS files" do
      create_owners_file("/a", ["heroku/developers"])
      create_owners_file("/b", [])
      create_pull_request_file("/a/a")
      create_pull_request_file("/a/b")
      expect(@pull_request.reload.ownership_users).to eq([[user("smiley")]])
    end

    it "ignores irrelevant OWNERS files" do
      create_owners_file("/", ["heroku/developers", "heroku/bread"])
      create_owners_file("/chef", ["heroku/ops"])

      create_pull_request_file("/chef/README")
      expect(@pull_request.reload.ownership_users).to eq([
        [user("alindeman"), user("sr")]
      ])
    end

    it "only applies glob to the current directory" do
      create_owners_file("/a", ["heroku/developers file.txt"])
      create_owners_file("/b", ["heroku/developers file.txt"])
      create_pull_request_file("/a/file.txt")
      expect(@pull_request.reload.ownership_users).to eq([[user("smiley")]])
    end
  end
end
