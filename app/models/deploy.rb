require "deployable"

class Deploy < ActiveRecord::Base
  include Deployable

  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user
  belongs_to :restart_server, class_name: Server

  has_many :results, class_name: DeployResult

  after_commit on: :create do |deploy|
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

  def all_servers
    all_sync_servers + all_pull_servers
  end

  def all_sync_servers
    self.servers_used.to_s.split(",").map(&:strip)
  end

  def all_pull_servers
    results.includes(:server).map { |result| result.server.hostname }
  end

  def sync_finished_servers
    self.completed_servers.to_s.split(",").map(&:strip)
  end

  def all_finished_servers
    sync_finished_servers + results.completed
  end

  def percentage_complete
    total_servers = all_servers.size
    if total_servers == 0
      percentage = 0
    else
      percentage = ((all_finished_servers.size / total_servers.to_f) * 100).to_i
      percentage = 100 if percentage > 100 # make sure we don't go over 100 (happens on retries)
    end
    percentage
  end

  def complete!
    update!(completed: true)
    Hipchat.notify_deploy_complete(self)
  end

  def cancel!
    update!(canceled: true, completed: true)
    Hipchat.notify_deploy_cancelled(self)
  end

  # TODO Replace the repo_name column with repo_id
  def repo
    Repo.find_by_name(repo_name)
  end

  def check_completed_status!
    return if completed?
    complete! unless incomplete_results_present?
  end

  def incomplete_results_present?
    results.incomplete.any?
  end
end
