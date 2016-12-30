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

  def organization
    @repo.name_with_owner.split("/")[0]
  end

  # Returns an Array of GitHub users referenced in the OWNERS file of this
  # repository, either by their username or through a team they belong to.
  def owners
    content = @github.file_content(
      @repo.name_with_owner,
      OWNERS_FILENAME,
      Changeling.config.repository_owners_file_branch
    )
    file = OwnersFile.new(content)

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

    file.users.each do |user|
      owners << user
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
end
