require "deployable"

class Deploy < ActiveRecord::Base
  include Deployable

  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user

  def log_path
    @_log_path ||= \
      begin
        filename = "#{self.deploy_target.name}_#{self.repo_name}_#{self.id}.log"
        File.join(ENV["CANOE_DIR"], 'log', filename)
      end
  end

  def log_contents
    return "" unless File.exists?(log_path)
    File.read(log_path)
  end

  # only grab the last X lines of the log output
  def some_log_contents(lines=50)
    `tail -n #{lines} #{log_path}`
  end

  def log_contents_htmlized(show_all=false)
    contents = show_all ? log_contents : some_log_contents
    contents.gsub(/\n/,"<br>")
  end

  def used_all_servers?
    self.specified_servers.blank?
  end

  def all_servers
    @_all_servers = self.servers_used.to_s.split(",").map(&:strip)
  end

  def finished_servers
    @_finished_servers = self.completed_servers.to_s.split(",").map(&:strip)
  end

  def percentage_complete
    ((finished_servers.size / all_servers.size.to_f) * 100).to_i
  end

  def complete!
    self.completed = true
    save!
  end

  def cancel!
    self.canceled = true
    save!
    kill_process!
  end

  def check_completed_status!
    # bail out if we are complete or we're still running...
    return if self.completed? || process_still_running?
    complete! # otherwise, mark as complete
  end

  def process_still_running?
    # look in the process list for our process ID.
    #     - remove any zombie process listings
    check = `ps cax | grep -v "\sZ[+]*\s" | grep -e "^\s*#{self.process_id}\s"`
    !check.blank?
  end

  def child_process_id
    # the process we spawn off is the sh process which yields another process
    `pgrep -P #{self.process_id}`
  end

  def kill_process!(forcefully=false)
    return true unless process_still_running?
    # -2 is INT which the ship-it script traps to report to hipchat
    `kill #{forcefully ? "-9" : "-2"} #{child_process_id}`
    sleep(1)
    check_completed_status!
  end

end
