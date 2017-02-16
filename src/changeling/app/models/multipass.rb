require_relative "./validators/sre_approver_is_in_sre"

# A change request in the system
class Multipass < ActiveRecord::Base
  audited

  belongs_to :github_repository, foreign_key: "repository_id"

  has_many :events
  has_many :peer_reviews
  has_many :pull_request_files

  has_one :story_ticket_reference, -> { where(ticket_type: TicketReference::TICKET_TYPE_STORY) }, class_name: "TicketReference"

  include Multipass::ActorVerification, Multipass::RequiredFields,
    Multipass::Updates, Multipass::GitHubStatuses,
    Multipass::Actions

  extend Multipass::IssueComments
  extend Multipass::PullRequestReview
  include PullRequestMethods

  before_save :update_complete
  after_commit :callback_to_github

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

  validates_with SREApproverIsInSRE

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
      update_column(:change_type, ChangeCategorization::STANDARD)
    end

    self[:change_type]
  end

  # Return true if the multipass was marked as completed just now.
  def just_completed?
    complete? && changes.keys.include?("complete")
  end

  def loggable_repository_name
    (repository_name || "").tr "/", "."
  end

  def repository
    Repository.find(repository_name)
  end

  def for_compliance?
    repository && repository.participating?
  end

  def repository_name
    if reference_url_path_parts.size == 5 && reference_url_path_parts[3] == "pull"
      reference_url_path_parts[1, 2].join("/")
    else
      nil
    end
  end

  def pull_request_number
    if reference_url_path_parts.size == 5 && reference_url_path_parts[3] == "pull"
      reference_url_path_parts[4]
    else
      nil
    end
  end

  def synchronize(current_github_login = nil)
    if Changeling.config.heroku?
      check_commit_statuses!
      self.audit_comment = "Browser: Sync commit statuses by #{current_github_login}"
      save!
    else
      repository_pull_request.synchronize
    end
  end

  def referenced_ticket
    repository_pull_request.referenced_ticket
  end

  # Returns an Array of filenames that were changed in this pull request
  def changed_files
    pull_request_files.pluck(:filename).map { |f| Pathname(f) }
  end

  # Returns an Array of GitHub user logins that approve of this change
  def peer_review_approvers
    peer_reviews.where(state: Clients::GitHub::REVIEW_APPROVED)
      .load.map(&:reviewer_github_login)
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

  def changed_risk_assessment?
    return false if audits.size == 1
    audits.any? do |audit|
      audit.audited_changes["impact"] != "low"
    end
  end

  delegate \
    :update_complete,
    :status,
    :github_commit_status_description,
    :complete?,
    :rejected?,
    :pending?,
    :peer_reviewed?,
    :user_is_peer_reviewer?,
    :sre_approved?,
    :user_is_sre_approver?,
    :emergency_approved?,
    :user_is_emergency_approver?,
    :user_is_rejector?,
    to: :compliance_status

  def status_description_html
    compliance_status.description_html
  end

  def reload
    @compliance_status = nil
    @repository_pull_request = nil
    super
  end

  private

  def repository_pull_request
    @repository_pull_request ||= RepositoryPullRequest.new(self)
  end

  def compliance_status
    @compliance_status ||= ComplianceStatus.new(self)
  end

  def reference_url_path_parts
    unless reference_url.present?
      return []
    end

    URI(reference_url).path.split("/")
  end
end
