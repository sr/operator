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
      !ticket_reference_missing?
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
      "Rejected by #{@multipass.rejector}"
    elsif emergency_approved?
      "Completed via emergency approval by #{@multipass.emergency_approver}."
    elsif ticket_reference_missing?
      "Ticket reference missing"
    elsif complete?
      "All requirements completed. Reviewed by #{@multipass.reviewers}."
    elsif @multipass.testing.nil?
      "Build pending"
    elsif !@multipass.testing
      "Build failed"
    else
      "Missing fields: #{@multipass.missing_fields.join(", ")}"
    end
  end

  private

  def ticket_reference_missing?
    if !@multipass.repository.ticket_reference_required?
      return false
    end

    @multipass.ticket_reference.nil?
  end
end
