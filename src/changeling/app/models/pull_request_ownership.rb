class PullRequestOwnership
  class GithubUser
    def initialize(login)
      @login = login
    end

    attr_reader :login

    def url
      "#{Changeling.config.github_url}/#{@login}"
    end
  end

  # Team represents a GitHub team.
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

  def initialize(multipass, pull_request, github_client)
    @multipass = multipass
    @pull_request = pull_request
    @github_client = github_client

    # Cache of all GitHub teams and their members referenced across OWNERS files
    @github_team_ids = {}
    @github_teams = {}

    # Nested Array of GitHub teams members
    @users = []

    load
  end

  # Returns the list of teams that need to approve the pull request
  def teams
    @github_teams.keys.map do |team|
      Team.new(@pull_request.repository_organization, team)
    end
  end

  # For each OWNERS file, returns the list of GitHub users that can approve this
  #
  # Example:
  #
  # [["sr", "alindeman"], ["lstoll"]]
  attr_reader :users

  # Returns the reviewer that has approved this pull request on the behalf of
  # a given team. If it no one from the given team has given an approvel yet,
  # this returns nil.
  def approver(team)
    login = @github_teams.fetch(team.slug).detect do |user_login|
      @multipass.peer_review_approvers.include?(user_login)
    end

    if login
      GithubUser.new(login)
    end
  end

  # Returns the list of OWNERS files that cover files being changed in this
  # pull request.
  def owners_files
    files = Set.new([])
    directories = {}

    @pull_request.repository_owners_files.reload.each do |file|
      directories[File.dirname(file.path_name)] = file
    end

    if directories.empty?
      return []
    end

    # If the pull request doesn't have any change, return the root OWNERS file,
    # or an empty Array if there is none
    if @multipass.changed_files.empty?
      return Array(directories["/"])
    end

    @multipass.changed_files.each do |file|
      file.ascend do |path|
        dirname = path.dirname.to_s

        if directories.key?(dirname)
          files.add(directories.fetch(dirname))
        end
      end
    end

    files.to_a
  end

  private

  def load
    @users.clear

    # Fetch all teams for this repository's organization
    @github_client.organization_teams(@pull_request.repository_organization).each do |team|
      @github_team_ids["#{@pull_request.repository_organization}/#{team.slug}"] = team.id
    end

    # Parse all OWNERS files and load the referenced teams and their members
    owners_files.each do |file|
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

        @github_client.team_members(@github_team_ids.fetch(team)).each do |user|
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
