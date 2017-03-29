class PardotComplianceStatus
  def initialize(multipass, pull_request)
    @multipass = multipass
    @pull_request = pull_request
    @default = HerokuComplianceStatus.new(multipass)
  end

  def complete?
    return true if emergency_approved?

    if !@multipass.missing_mandatory_fields.empty?
      return false
    end

    # Unless merged, an open ticket reference is required
    if !@multipass.merged? && (ticket_reference_missing? || !referenced_ticket_open?)
      return false
    end

    if sre_approval_required? && !sre_approved?
      return false
    end

    peer_reviewed? && tests_successful?
  end

  def rejected?
    return false if emergency_approved?

    @default.rejected?
  end

  def pending?
    return false if complete?

    if tests_failed?
      return false
    end

    tests_pending? || !peer_reviewed?
  end

  def user_is_peer_reviewer?(user)
    @default.user_is_peer_reviewer?(user)
  end

  def sre_approved?
    sres = GithubInstallation.current.team_members(Changeling.config.sre_team_slug)
    reviewers = @multipass.peer_review_approvers
    !(sres & reviewers).empty?
  end

  def sre_approval_required?
    @multipass.change_type == ChangeCategorization::MAJOR
  end

  def user_is_sre_approver?(_user)
    raise NotImplementedError
  end

  def emergency_approved?
    @multipass.change_type == ChangeCategorization::EMERGENCY
  end

  def user_is_emergency_approver?(user)
    @default.user_is_emergency_approver?(user)
  end

  def user_is_rejector?(user)
    @default.user_is_rejector?(user)
  end

  def peer_reviewed?
    if !Changeling.config.owners_files_enabled?
      return @multipass.reviewer.present?
    end

    reviewers = @multipass.peer_review_approvers
    owners = @pull_request.ownership_users

    if owners.empty?
      return false
    end

    # Returns true if at least one of the owners for each of the affected
    # components have reviewed and approved the pull request.
    owners.all? do |team|
      reviewers.any? { |r| team.include?(r) }
    end
  end

  def github_commit_status_description
    if rejected?
      "Changes requested by #{@multipass.rejector}"
    elsif emergency_approved?
      "Satisfied via emergency approval."
    elsif complete?
      "Satisfied. Reviewed by #{@multipass.reviewers}."
    elsif ticket_reference_missing?
      "Ticket reference is missing"
    elsif !referenced_ticket_open?
      "Referenced ticket is not open"
    elsif tests_pending?
      "Awaiting automated tests results"
    elsif !tests_successful?
      "Automated tests failed"
    elsif !peer_reviewed?
      "Review by one or more component(s) owner(s) is missing"
    elsif sre_approval_required? && !sre_approved?
      "Review by the SRE team is required and is missing"
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

  def tests_failed?
    !tests_pending? && !tests_successful?
  end
end