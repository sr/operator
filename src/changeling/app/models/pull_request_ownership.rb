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
  class GithubTeam
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
  end

  # Returns the list of GitHub team slugs (e.g. @Pardot/bread) mentioned across
  # the OWNERS files relevant to this pull request.
  def teams
    slugs = Set.new([])

    parsed_owners_files.each do |file|
      slugs.merge(file.teams)
    end

    slugs.map do |slug|
      GithubTeam.new(@pull_request.repository_organization, slug)
    end
  end

  # For each OWNERS file, returns the list of GitHub users that can approve this
  #
  # Example:
  #
  # [["sr", "alindeman"], ["lstoll"]]
  def users
    users = []

    parsed_owners_files.each do |owners_file|
      users << GithubInstallation.current.team_members(owners_file.teams)
    end

    users
  end

  # Returns the reviewer that has approved this pull request on the behalf of
  # a given team. If it no one from the given team has given an approvel yet,
  # this returns nil.
  def approver(team)
    login = GithubInstallation.current.team_members(team).detect do |user_login|
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

    @pull_request.repository_owners_files.each do |file|
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

  def parsed_owners_files
    owners_files.map do |file|
      OwnersFile.new(file.content)
    end
  end
end
