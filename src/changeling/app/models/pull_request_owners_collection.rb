class PullRequestOwnersCollection
  class Team
    def initialize(organization, team)
      @organization = organization
      @slug = team
    end

    attr_reader :slug

    def url
      "#{Changeling.config.github_url}/orgs/#{@organization}/teams/#{name}"
    end

    private

    def name
      @slug.split("/").last
    end
  end

  def initialize(pull_request, github_client)
    @pull_request = pull_request
    @github_client = github_client

    # Cache of all GitHub teams and their members referenced across OWNERS files
    @github_team_ids = {}
    @github_teams = {}

    # Nested Array of GitHub teams members
    @users = []
  end

  attr_reader :users

  def teams
    @github_teams.keys.map do |team|
      Team.new(@pull_request.repository_organization, team)
    end
  end

  def load
    @users.clear

    # Fetch all teams for this repository's organization
    @github_client.organization_teams(@pull_request.repository_organization).each do |team|
      @github_team_ids["#{@pull_request.repository_organization}/#{team.slug}"] = team.id
    end

    # Parse all OWNERS files and load the referenced teams and their members
    @pull_request.owners_files.each do |file|
      file = OwnersFile.new(file.content)
      component_users = Set.new([])

      # Load the referenced teams and their members
      file.teams.each do |team|
        # Ignore teams that don't belong to this repository's organization
        if !@github_team_ids.key?(team)
          next
        end

        # Avoid fetching members of the same team twice
        if @github_teams.key?(team)
          component_users.merge(@github_teams.fetch(team))

          next
        end

        members = Set.new([])

        @github_client.team_members2(@github_team_ids.fetch(team)).each do |user|
          members.add(user.login)
        end

        @github_teams[team] = members
        component_users.merge(members)
      end

      @users << component_users.to_a
    end

    self
  end
end
