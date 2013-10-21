class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  has_many :locks
  belongs_to :locking_user, class_name: AuthUser


  def last_deploy_for(repo_name)
    self.deploys.where(repo_name: repo_name).order("created_at DESC").first
  end

  def active_deploy
    # see if the most recent deploy is not completed
    @_active_deploy ||= most_recent_deploy.try(:completed) ? nil : most_recent_deploy
  end

  def most_recent_deploy
    @_most_recent_deploy ||= self.deploys.order("created_at DESC").first
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

  def has_file_lock?
    File.exists?(self.lock_path)
  end

  def file_lock_user
    return nil unless File.exists?(self.lock_path)
    File.read(self.lock_path).chomp
  end

end