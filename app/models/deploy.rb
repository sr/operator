require "deployable"

class Deploy < ActiveRecord::Base
  include Deployable

  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user

  has_many :results, class_name: DeployResult

  def log_path
    @_log_path ||= \
      begin
        filename = "#{self.deploy_target.name}_#{self.repo_name}_#{self.id}.log"
        Rails.root.join('log', filename).to_s
      end
  end

  def log_contents
    return "" unless File.exist?(log_path)
    File.read(log_path, :encoding => "UTF-8")
  end

  # only grab the last X lines of the log output
  def some_log_contents(lines=50)
    IO.popen(["tail", "-n", lines.to_s, log_path]) { |io| io.read }
  end

  def log_contents_htmlized(show_all=false)
    contents = show_all ? log_contents : some_log_contents
    contents.gsub(/\n/,"<br>").html_safe
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
    percentage = ((finished_servers.size / all_servers.size.to_f) * 100).to_i
    percentage = 100 if percentage > 100 # make sure we don't go over 100 (happens on retries)
    percentage
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
    return false if process_id.nil?

    # kill -0 checks if the process is running and owned by us, but doesn't send
    # a signal
    !!Process.kill(0, process_id.to_i)
  rescue
    # process isn't running or isn't owned by us
    false
  end

  def kill_process!(forcefully=false)
    return unless process_still_running?
    Process.kill(forcefully ? "KILL" : "INT", process_id.to_i)
    sleep(1)
    check_completed_status!
  end
end
