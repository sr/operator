# A way to find out info about a GitHub Repository
class Repository
  OWNERS_FILENAME = "OWNERS".freeze

  class OwnersError < StandardError
  end

  def self.team_for(name_with_owner)
    find(name_with_owner).team
  end

  def self.participating?(name_with_owner)
    find(name_with_owner).participating?
  end

  def self.find(name_with_owner)
    if Changeling.config.pardot?
      new(PardotRepository.new(name_with_owner))
    else
      new(HerokuRepository.new(name_with_owner))
    end
  end

  def initialize(repo)
    @repo = repo
    @github = Clients::GitHub.new(Changeling.config.github_service_account_token)
  end

  def name_with_owner
    @repo.name_with_owner
  end

  def name
    @repo.name_with_owner.split("/")[1]
  end

  def organization
    @repo.name_with_owner.split("/")[0]
  end

  def synchronize_owners_files
    # The GitHub search API returns empty results when the search backend is
    # unavailable. To avoid syncing bad data, we first perform a query that is
    # known to always return results and abort the synchronization process if it
    # looks like the API is having availability issues.
    if @github.search_code("user:#{organization} changeling").total_count == 0
      return
    end

    repository = GithubRepository.find_by!(owner: organization, name: name)

    owners_files = []

    query = "in:path filename:#{OWNERS_FILENAME} repo:#{@repo.name_with_owner}"
    results = @github.search_code(query)

    results.items.each do |item|
      if item.name != OWNERS_FILENAME
        next
      end

      content = @github.file_content(@repo.name_with_owner, item.path, nil)

      if content.empty?
        next
      end

      path_name =
        if item.path[0] == "/"
          item.path
        else
          "/#{item.path}"
        end

      owners_files << RepositoryOwnersFile.new(
        repository_id: repository.id,
        path_name: path_name,
        content: content
      )
    end

    RepositoryOwnersFile.transaction do
      RepositoryOwnersFile.where(repository_id: github_repository.id).delete_all
      owners_files.map(&:save!)
    end
  end

  # Returns all OWNERS files included in this repository
  def owners_files
    github_repository.repository_owners_files
  end

  # Returns an Array of GitHub users referenced in the OWNERS file of this
  # repository, either by their username or through a team they belong to.
  def owners
    owners_file = owners_files.find_by(path_name: "/#{OWNERS_FILENAME}")

    if owners_file.nil?
      return []
    end

    file = OwnersFile.new(owners_file.content)

    owners = []
    team_slugs = []

    file.teams.each do |team|
      parts = team.split("/")

      # Ignore teams that don't belong to this repository's organization
      if parts[0] != organization
        next
      end

      team_slugs << parts[1]
    end

    @github.team_members(organization, team_slugs).each do |user|
      owners << user.login
    end

    owners.uniq
  end

  def required_testing_statuses
    @repo.required_testing_statuses
  end

  def update_github_commit_status?
    @repo.update_github_commit_status?
  end

  def ticket_reference_required?
    @repo.ticket_reference_required?
  end

  def participating?
    @repo.participating?
  end

  def team
    @repo.team
  end

  private

  def github_repository
    GithubRepository.find_by!(owner: organization, name: name)
  end
end
