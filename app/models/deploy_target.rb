class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  has_many :locks
  belongs_to :locking_user, class_name: AuthUser

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

  def active_deploy
    # see if the most recent deploy is not completed
    most_recent_deploy.try(:completed) ? nil : most_recent_deploy
  end

  def most_recent_deploy
    self.deploys
      .order(id: :desc)
      .first
  end

  def lock!(user)
    self.locked = true
    self.locking_user = user
    self.save

    self.locks.create(auth_user: user, locking: true)
  end

  def unlock!(user, forced=false)
    self.locked = false
    self.locking_user = nil
    self.save

    self.locks.create(auth_user: user, locking: false, forced: forced)
  end

  def is_locked?
    self.locked? || has_file_lock?
  end

  def name_of_locking_user
    if has_file_lock?
      file_lock_user
    else
      self.locking_user.try(:email)
    end
  end

  def has_file_lock?
    File.exist?(self.lock_path)
  end

  def file_lock_user
    return nil unless File.exist?(self.lock_path)
    File.read(self.lock_path, :encoding => "UTF-8").chomp
  end

  def file_lock_time
    return Time.now unless has_file_lock?
    File.ctime(self.lock_path)
  end

  # user can deploy if the target isn't locked or they are the ones with the current lock
  def user_can_deploy?(user)
    ! is_locked? || \
    self.locking_user == user || \
    self.file_lock_user == user.email
  end

  def servers(repo:)
    Server
      .joins(:deploy_scenarios)
      .where(deploy_scenarios: {deploy_target_id: id, repo_id: repo.id})
  end
end
