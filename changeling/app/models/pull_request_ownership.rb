class PullRequestOwnership
  def initialize(multipass, pull_request, github_client)
    @multipass = multipass
    @pull_request = pull_request
    @github_client = github_client
  end

  # Returns the list of GitHub team slugs (e.g. @Pardot/bread) that must
  # review and approve the pull request, based on ownership data.
  def teams
    _files, slugs = load_ownership_data

    slugs.map do |slug|
      GithubTeam.new(slug)
    end
  end

  # For every team that must review this pull request, returns the list of
  # GitHub users that are allowed to approve the PR on behalf of the team.
  #
  # Example:
  #
  # [["sr", "alindeman"], ["lstoll"]]
  def users
    teams_members = []

    teams.each do |team|
      members = GithubInstallation.current.team_members(team.slug)

      if members.any?
        teams_members << members
      end
    end

    teams_members
  end

  # Returns the reviewer that has approved this pull request on the behalf of
  # a given team. If no one from the team has given approval yet,
  # this returns nil.
  def approver(team)
    approvers = @multipass.peer_review_approvers
    GithubInstallation.current.team_members(team).detect do |user|
      approvers.include?(user)
    end
  end

  # Returns the list of OWNERS files that cover files and directories being
  # changed in this pull request.
  def owners_files
    files, _slugs = load_ownership_data
    files.to_a
  end

  private

  def load_ownership_data
    files = Set.new([])
    slugs = Set.new([])

    by_directory = {}
    @pull_request.repository_owners_files.each do |file|
      by_directory[File.dirname(file.path_name)] = file
    end

    # If the repository doesn't have any OWNERS file, returns an empty list
    # of files and teams. This means the pull request can never be approved
    # and will be blocked until a valid OWNERS file is added at the root of
    # the repository.
    if by_directory.empty?
      return [], []
    end

    # Similarly, if the pull request doesn't have any change, pretend that the
    # the root /OWNERS file is being changed, effectively causing it to take
    # effect.
    changed_files =
      if @multipass.changed_files.empty?
        [Pathname("/OWNERS")]
      else
        @multipass.changed_files
      end

    changed_files.each do |file|
      # An OWNERS file with glob patterns may only match files in the same
      # directory.
      dirname = file.dirname.to_s
      if by_directory.key?(dirname)
        owners_file = by_directory.fetch(dirname)
        owners_file.parse

        matched_glob = false
        owners_file.parsed.globs.each do |glob, team|
          next unless File.fnmatch?(glob, file.basename)

          matched_glob = true
          files.add(owners_file)
          slugs.add(team)
        end

        # If the file matched at least one glob its own directory, we don't need
        # to look at anything else.
        next if matched_glob
      end

      file.ascend do |path|
        dirname = path.dirname.to_s
        if by_directory.key?(dirname)
          owners_file = by_directory.fetch(dirname)
          owners_file.parse

          files.add(owners_file)
          slugs.merge(owners_file.parsed.teams)
          break
        end
      end
    end

    [files, slugs]
  end
end
