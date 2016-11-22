# A way to find out info about a GitHub Repository
class Repository
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
  end

  def name_with_owner
    @repo.name_with_owner
  end

  def required_testing_statuses
    @repo.required_testing_statuses
  end

  def update_github_commit_status?
    @repo.update_github_commit_status?
  end

  def participating?
    @repo.participating?
  end

  def synchronize_commit_status(github_id, commit_status)
    attributes = {
      github_repository_id: github_id,
      sha: commit_status.sha,
      context: commit_status.context
    }

    status = RepositoryCommitStatus.find_or_initialize_by(attributes) do |s|
      s.state = commit_status.state
    end
    status.save!
    status
  end

  def team
    @repo.team
  end
end
