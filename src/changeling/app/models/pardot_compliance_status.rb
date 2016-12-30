class PardotComplianceStatus
  def initialize(multipass)
    @multipass = multipass
    @default = HerokuComplianceStatus.new(multipass)
  end

  delegate \
    :complete?,
    :rejected?,
    :pending?,
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

  def peer_reviewed?
    if !Changeling.config.repository_owners_review_required.include?(@multipass.repository_name)
      return @multipass.peer_reviewer.present?
    end

    reviewers = @multipass.peer_review_approvers
    owners = @multipass.repository_owners

    if owners.empty?
      raise Repository::OwnersError, "repository #{@multipass.repository_name.inspect} does not have any owner"
    end

    owners.any? do |owner|
      reviewers.include?(owner)
    end
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

    if @multipass.referenced_ticket
      @multipass.referenced_ticket.open?
    end
  end

  def ticket_reference_missing?
    if !@multipass.repository.ticket_reference_required?
      return false
    end

    @multipass.referenced_ticket.nil?
  end

  def tests_successful?
    @multipass.tests_state == RepositoryCommitStatus::SUCCESS
  end

  def tests_pending?
    @multipass.tests_state == RepositoryCommitStatus::PENDING
  end
end
