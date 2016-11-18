require_relative "./validators/callback_url_is_valid"
require_relative "./validators/sre_approver_is_in_sre"

# A change request in the system
class Multipass < ActiveRecord::Base
  audited
  has_many :events

  include Multipass::ActorVerification, Multipass::RequiredFields,
    Multipass::State, Multipass::Updates, Multipass::GitHubStatuses,
    Multipass::Actions

  extend Multipass::IssueComments
  extend Multipass::PullRequestReview
  include PullRequestMethods

  REPOSITORY_REGEX = %r{https://github\.com/([-_\.0-9a-z]+/[-_\.0-9a-z]+)/pull/(\d+)}

  before_save :update_complete
  after_save :log_completed
  after_commit :callback_to_github
  after_create :log_created

  scope :by_team, lambda { |team|
    return if team.blank?
    where(team: team)
  }

  scope :complete, lambda { |complete|
    return if complete.nil?
    where(complete: complete)
  }

  scope :questionable, lambda {
    where(testing: false).where(["updated_at > ?", 5.minutes.ago])
  }

  validates_with SREApproverIsInSRE, CallbackUrlIsValid

  validates :requester, :reference_url, :team, presence: true
  validates_each :sre_approver, :peer_reviewer do |record, attr, value|
    if record.requester == value || record.requester == User.for_github_login(value)
      record.errors.add attr, "may not be the same as the requester"
    end
  end

  def self.teams
    Multipass.pluck("distinct team").sort
  end

  def self.find_questionable
    questionable.map do |multipass|
      multipass if multipass.missing_fields == [:testing]
    end.compact
  end

  def change_type
    if self[:change_type] == "preapproved"
      update_column(:change_type, "minor")
    end

    self[:change_type]
  end

  def log_completed
    return true unless just_completed?
    ActiveSupport::Notifications.instrument("multipass.completed", multipass: self)
  end

  # Return true if the multipass was marked as completed just now.
  def just_completed?
    complete? && changes.keys.include?("complete")
  end

  def loggable_repository_name
    (repository_name || "").tr "/", "."
  end

  def repository
    Repository.new(repository_name)
  end

  def for_compliance?
    repository && repository.participating?
  end

  def repository_name
    match = reference_url.match(REPOSITORY_REGEX)
    return nil unless match
    match[1]
  end

  def pull_request_number
    match = reference_url.match(REPOSITORY_REGEX)
    return nil unless match
    match[2]
  end

  def hostname
    ENV["HOST"] || "changeling-development.heroku.tools"
  end

  def permalink
    "https://#{hostname}/multipasses/#{uuid}"
  end

  def reviewers
    [peer_reviewer, sre_approver].compact.uniq.join(", ")
  end

  def human_missing_conditional_fields
    human_names = {
      peer_reviewer: "Peer review",
      sre_approver: "SRE approval"
    }
    message = missing_conditional_fields.map do |field|
      "#{human_names[field]} ✗"
    end.join(", ") + "."
    unless reviewers.blank?
      message += " Reviewed by #{reviewers}."
    end
    message
  end

  def approve_from_api_comment(user, text, url)
    Audited::Audit.as_user(user) do
      self.audit_comment = "API: Updated from webhook '#{text}' - #{url}"
      self.peer_reviewer = user.github_login
      if save
        check_commit_statuses!
        ActiveSupport::Notifications.instrument("multipass.peer_review", from: "github")
        true
      else
        Rails.logger.info "Unable to approve multipass #{id}:" \
          "#{self.errors.full_messages.join('. ')}"
      end
    end
  end

  def approve_from_review(user, text, url)
    Audited::Audit.as_user(user) do
      self.audit_comment = "API: Updated from PullRequest Review webhook '#{text}' - #{url}"
      self.peer_reviewer = user.github_login
      if save
        check_commit_statuses!
        ActiveSupport::Notifications.instrument("multipass.peer_review", from: "github")
        true
      else
        Rails.logger.info "Unable to approve multipass #{id}:" \
          "#{self.errors.full_messages.join('. ')}"
      end
    end
  end

  def remove_approval_from_review(user, text, url)
    Audited::Audit.as_user(user) do
      self.audit_comment = "API: Updated from PullRequest Review webhook '#{text}' - #{url}"
      remove_review(user.github_login)
    end
  end

  def to_pretty_json
    JSON.pretty_generate(self.attributes)
  end

  def api_response_hash
    attributes.tap do |attributes|
      attributes[:status] = status
      attributes[:permalink] = permalink
    end
  end

  def log_created
    Metrics.increment("multipasses.created.#{loggable_repository_name}")
    Metrics.increment("multipasses.created")
  end
end
