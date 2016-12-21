class PardotComplianceStatus
  def initialize(multipass)
    @multipass = multipass
    @default = HerokuComplianceStatus.new(multipass)
  end

  delegate \
    :complete?,
    :rejected?,
    :pending?,
    :peer_reviewed?,
    :emergency_approved?,
    to: :@default

  def complete?
    @multipass.missing_mandatory_fields.empty? &&
      !ticket_reference_missing? &&
      referenced_ticket_open? &&
      peer_reviewed? &&
      tests_successful?
  end

  def user_is_peer_reviewer?(user)
    @default.user_is_peer_reviewer?(user)
  end

  def sre_approved?
    false
  end

  def user_is_sre_approver?(_user)
    raise NotImplementedError
  end

  def user_is_emergency_approver?(user)
    @default.user_is_emergency_approver?(user)
  end

  def user_is_rejector?(user)
    @default.user_is_rejector?(user)
  end

  def github_commit_status_description
    if rejected?
      "Changes requested by #{@multipass.rejector}"
    elsif !peer_reviewed?
      "Peer review is required"
    elsif emergency_approved?
      "Satisfied via emergency approval by #{@multipass.emergency_approver}."
    elsif ticket_reference_missing?
      "Ticket reference is missing"
    elsif !referenced_ticket_open?
      "Referenced ticket is not open"
    elsif complete?
      "Satisfied. Reviewed by #{@multipass.reviewers}."
    elsif tests_pending?
      "Awaiting automated tests results"
    elsif !tests_successful?
      "Automated tests failed"
    else
      "Missing fields: #{@multipass.missing_fields.join(", ")}"
    end
  end

  private

  def referenced_ticket_open?
    if !@multipass.repository.ticket_reference_required?
      return true
    end

    @multipass.ticket_reference.open?
  end

  def ticket_reference_missing?
    if !@multipass.repository.ticket_reference_required?
      return false
    end

    @multipass.ticket_reference.nil?
  end

  def tests_successful?
    @multipass.tests_state == RepositoryCommitStatus::SUCCESS
  end

  def tests_pending?
    @multipass.tests_state == RepositoryCommitStatus::PENDING
  end
end
