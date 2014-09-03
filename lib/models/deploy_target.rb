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

  def shipit_command(cmd_options=[])
    cmd_pieces = []
    cmd_pieces << "cd #{self.script_path} &>/dev/null;"
    cmd_pieces << "PATH=$PATH:/usr/local/bin bundle exec ./ship-it.rb"
    cmd_pieces << self.name.downcase # always pass env
    cmd_pieces += cmd_options
    cmd_pieces.compact!

    cmd_pieces.join(" ")
  end

  # returns "tuple" with count and comma separated list of servers (string)
  def gather_complete_server_list(options)
    # call the ship-it script to get a full list of servers
    cmd_options = ["--list-servers"]
    cmd_options << shipit_server_flag(options)
    server_list = `#{shipit_command(cmd_options)}`.strip
    [server_list.split(",").size, server_list]
  end

  def shipit_server_flag(options)
    if options[:servers]
      "--servers=\"#{options[:servers].gsub(/\s/,"")}\""
    else
      nil
    end
  end

  def deploy!(options = {})
    [:user, :repo, :what, :what_details].each do |arg|
      unless options.keys.include?(arg)
        raise "Required option, #{arg.to_s}, is missing from deploy options."
      end
    end

    server_count, server_list = gather_complete_server_list(options)

    # build options ot pass to ship-it
    cmd_options = []
    cmd_options << options[:repo].name
    cmd_options << "#{options[:what]}=#{options[:what_details]}"

    # need to go ahead and create this since we need the ID to pass to ship-it
    deploy = self.deploys.create( auth_user: options[:user],
                                  repo_name: options[:repo].name,
                                  what: options[:what],
                                  what_details: options[:what_details],
                                  completed: false,
                                  specified_servers: options[:servers],
                                  server_count: server_count,
                                  servers_used: server_list,
                                  )

    cmd_options << "--lock" if options[:lock]
    cmd_options << "--user=#{options[:user].email}"
    cmd_options << "--deploy-id=#{deploy.id}"
    cmd_options << shipit_server_flag(options)
    cmd_options << "--no-confirmations"
    cmd_options << "--html-color"
    cmd_options << "&> #{deploy.log_path}"

    self.lock!(options[:user]) if options[:lock]

    # spawn process to run this...
    shipit_pid = spawn(shipit_command(cmd_options))
    deploy.update_attribute(:process_id, shipit_pid)

    # return the deploy for good measure
    deploy
  end

end
