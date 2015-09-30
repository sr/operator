require "deployable"

class Deploy < ActiveRecord::Base
  include Deployable

  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user

  has_many :results, class_name: DeployResult
  after_create do |deploy|
    Hipchat.notify_deploy_start(deploy)
    Hipchat.notify_untested_deploy(deploy) if Rails.env.production? && !deploy.passed_ci
  end

  scope :reverse_chronological, -> { order(created_at: :desc) }

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
    all_sync_servers + all_pull_servers
  end

  def all_sync_servers
    self.servers_used.to_s.split(",").map(&:strip)
  end

  def all_pull_servers
    results.includes(:server).map { |result| result.server.hostname }
  end

  def finished_servers
    @_finished_servers = self.completed_servers.to_s.split(",").map(&:strip)
  end

  def percentage_complete
    percentage = ((finished_servers.size / all_sync_servers.size.to_f) * 100).to_i
    percentage = 100 if percentage > 100 # make sure we don't go over 100 (happens on retries)
    percentage
  end

  def complete!
    update!(completed: true)
    Hipchat.notify_deploy_complete(self)
  end

  def cancel!
    update!(canceled: true, completed: true)
    kill_process!
    Hipchat.notify_deploy_cancelled(self)
  end

  # TODO Replace the repo_name column with repo_id
  def repo
    Repo.find_by_name(repo_name)
  end

  def check_completed_status!
    return if completed?

    if !process_still_running? && !pending_results_present?
      complete!
    end
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

  def pending_results_present?
    results.pending.any?
  end

  def kill_process!(forcefully=false)
    return unless process_still_running?
    Process.kill(forcefully ? "KILL" : "INT", process_id.to_i)
    sleep(1)
    check_completed_status!
  end
end
