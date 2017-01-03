# A way to find out info about a GitHub Repository
class Repository
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

  Owner = Struct.new(:github_login)

  def owners
    content = @github.file_content(@repo.name_with_owner, "OWNERS")

    OwnersFile.new(content).users
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
