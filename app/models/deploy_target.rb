class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  has_many :locks
  belongs_to :locking_user, class_name: AuthUser

  scope :enabled, -> { where(enabled: true) }

  def to_param
    name
  end

  def last_deploy_for(repo_name)
    self.deploys
      .where(repo_name: repo_name)
      .order(id: :desc)
      .first
  end

  def last_successful_deploy_for(repo_name)
    self.deploys
      .where(
        repo_name: repo_name,
        completed: true,
        canceled:  false)
      .order(id: :desc)
      .first
  end

  def previous_deploy(deploy)
    self.deploys
      .where(repo_name: deploy.repo_name)
      .where("id < ?", deploy.id)
      .order(id: :desc)
      .first
  end

  def previous_successful_deploy(deploy)
    self.deploys
      .where(
        repo_name: deploy.repo_name,
        completed: true,
        canceled:  false)
      .where("id < ?", deploy.id)
      .order(id: :desc)
      .first
  end

  def active_deploy(repo)
    if latest_deploy = most_recent_deploy(repo)
      latest_deploy unless latest_deploy.completed?
    end
  end

  def most_recent_deploy(repo)
    self.deploys
      .where(repo_name: repo.name)
      .order(id: :desc)
      .first
  end

  def lock!(repo, user)
    locks.find_or_create_by!(repo: repo, auth_user: user)
  end

  def unlock!(repo, user)
    locks.where(repo: repo).destroy_all
  end

  # Finds an existing lock on the target and repo
  def existing_lock(repo)
    locks.where(repo: repo).first
  end

  def user_can_deploy?(repo, user)
    lock = existing_lock(repo)
    lock.nil? || lock.auth_user == user
  end

  def servers(repo:)
    Server
      .joins(:deploy_scenarios)
      .where(deploy_scenarios: {deploy_target_id: id, repo_id: repo.id})
  end
end
