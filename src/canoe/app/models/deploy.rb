require "json_schema"

class Deploy < ApplicationRecord
  belongs_to :deploy_target
  belongs_to :auth_user
  has_many :restart_servers, class_name: Server, through: :deploy_restart_servers, source: :server
  has_many :deploy_restart_servers
  has_many :results, class_name: DeployResult

  serialize :options, JSON
  serialize :options_validator, JSON

  validate :options_are_valid

  after_commit on: :create do |deploy|
    next unless deploy.project.present?
    deploy.project.deploy_notifications.each do |notification|
      notification.notify_deploy_start(deploy)
      notification.notify_untested_deploy(deploy) if deploy.deploy_target.production? && !deploy.passed_ci
    end
  end

  scope :reverse_chronological, -> { order(created_at: :desc) }

  def log_path
    @_log_path ||= \
      begin
        filename = "#{deploy_target.name}_#{project_name}_#{id}.log"
        Rails.root.join("log", filename).to_s
      end
  end

  def log_contents
    return "" unless File.exist?(log_path)
    File.read(log_path, encoding: "UTF-8")
  end

  # only grab the last X lines of the log output
  def some_log_contents(lines = 50)
    IO.popen(["tail", "-n", lines.to_s, log_path], &:read)
  end

  def log_contents_htmlized(show_all = false)
    contents = show_all ? log_contents : some_log_contents
    contents.gsub(/\n/, "<br>").html_safe
  end

  def all_servers
    all_sync_servers + all_pull_servers
  end

  def all_sync_servers
    servers_used.to_s.split(",").map(&:strip)
  end

  def all_pull_servers
    results.includes(:server).map { |result| result.server.hostname }
  end

  def sync_finished_servers
    completed_servers.to_s.split(",").map(&:strip)
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

    if project.present?
      project.deploy_notifications.each do |notification|
        notification.notify_deploy_complete(self)
      end
    end
  end

  def cancel!
    update!(canceled: true, completed: true)

    if project.present?
      project.deploy_notifications.each do |notification|
        notification.notify_deploy_cancelled(self)
      end
    end
  end

  # TODO: Replace the project_name column with project_id
  def project
    Project.find_by_name(project_name)
  end

  def check_completed_status!
    return if completed?
    complete! unless incomplete_results_present?
  end

  def incomplete_results_present?
    results.incomplete.any?
  end

  def sync_done?
    !results.initiated.any?
  end

  def options_are_valid
    if options_validator.present?
      validator = JsonSchema.parse!(options_validator)
      _, errors = validator.validate(options || {})
      errors.each do |error|
        self.errors.add("options", error.to_s)
      end
    end
  end
end
