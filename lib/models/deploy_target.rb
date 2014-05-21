class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  has_many :locks
  has_many :jobs, class_name: TargetJob
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

  def active_job
    @_active_job ||= most_recent_job.try(:completed) ? nil : most_recent_job
  end

  def most_recent_job
    @_most_recent_job ||= self.jobs.order("created_at DESC").first
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
    File.exists?(self.lock_path)
  end

  def file_lock_user
    return nil unless File.exists?(self.lock_path)
    File.read(self.lock_path).chomp
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

  def deploy!(options = {})
    [:user, :repo, :what, :what_details].each do |arg|
      unless options.keys.include?(arg)
        raise "Required option, #{arg.to_s}, is missing from deploy options."
      end
    end

    cmd_pieces = []
    cmd_pieces << "PATH=$PATH:/usr/local/bin"
    cmd_pieces << self.script_path + "/ship-it.rb"
    cmd_pieces << self.name.downcase
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

    # spawn process to run this...
    shipit_pid = spawn(cmd_pieces.join(" "))
    deploy.update_attribute(:process_id, shipit_pid)

    # return the deploy for good measure
    deploy
  end

  def reset_database!(options = {})
    # gather the location of the pardot deploy
    directory = `#{self.script_path}/ship-it.rb --remote-pardot-path`.chomp
    cmd_pieces = []
    cmd_pieces << "cd #{directory};"
    if self.name == "dev"
      cmd_pieces << "sh batch/devResetAll.sh"
    elsif self.name == "test"
      cmd_pieces << "cd ../;" # back up a dir...
      cmd_pieces << "sudo CANOE_USER=#{options[:user].email} sh update-test-reset"
    else
      return
    end

    job = self.jobs.create( auth_user: options[:user],
                            command: "",
                            job_name: "Database Reset",
                            )

    # we need job to be created so we can get the proper log path...
    cmd_pieces << "&> #{job.log_path}"

    job.command = cmd_pieces.join(" ")
    job.save!

    rake_env = { "JOB_ID" => job.id.to_s }
    rake_cmd = "bundle exec rake canoe:run_job"
    # spawn process to run the rake command...
    # rake_pid = \
    spawn(rake_env, rake_cmd)

    # return job for good measure
    job
  end

end
