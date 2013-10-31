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

  # user can deploy if the target isn't locked or they are the ones with the current lock
  def user_can_deploy?(user)
    ! is_locked? || \
    self.locking_user == user || \
    self.file_lock_user == user.email
  end

  def deploy!(options = {})
    [:user, :repo, :what, :what_details].each do |arg|
      unless options.keys.include?(arg)
        raise "Required option, #{arg.to_s}, is missing from deploy options."
      end
    end

    cmd_pieces = []
    cmd_pieces << self.script_path + "/ship-it.rb"
    cmd_pieces << options[:repo].name
    cmd_pieces << "#{options[:what]}=#{options[:what_details]}"

    # need to go ahead and create this since we need the ID to pass to ship-it
    deploy = self.deploys.create( auth_user: options[:user],
                                  repo_name: options[:repo].name,
                                  what: options[:what],
                                  what_details: options[:what_details],
                                  completed: false,
                                  )

    cmd_pieces << "--lock" if options[:lock]
    cmd_pieces << "--user=#{options[:user].email}"
    cmd_pieces << "--deploy-id=#{deploy.id}"
    cmd_pieces << "--no-confirmations"
    cmd_pieces << "&> #{deploy.log_path}"

    self.lock!(options[:user]) if options[:lock]

    # fork off process to run this...
    shipit = fork { exec cmd_pieces.join(" ") }
    Process.detach(shipit)

    # return the deploy for good measure
    deploy
  end

end