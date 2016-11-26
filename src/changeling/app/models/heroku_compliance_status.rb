class HerokuComplianceStatus
  def initialize(multipass)
    @multipass = multipass
  end

  def complete?
    return true if @multipass.emergency_approver
    @multipass.missing_fields.empty?
  end

  def rejected?
    return true if @multipass.rejector
    false
  end

  def pending?
    !complete? && !@multipass.merged
  end

  def peer_reviewed?
    @multipass.peer_reviewer.present?
  end

  def user_is_peer_reviewer?(user)
    @multipass.peer_reviewer == user
  end

  def sre_approved?
    @multipass.sre_approver.present?
  end

  def user_is_sre_approver?(user)
    @multipass.sre_approver == user
  end

  def emergency_approved?
    @multipass.emergency_approver.present?
  end

  def user_is_emergency_approver?(user)
    @multipass.emergency_approver == user
  end

  def user_is_rejector?(user)
    @multipass.rejector == user
  end

  def github_commit_status_description
    if rejected?
      "Rejected by #{@multipass.rejector}"
    elsif emergency_approved?
      "Completed via emergency approval by #{@multipass.emergency_approver}."
    elsif @multipass.missing_conditional_fields.any?
      @multipass.human_missing_conditional_fields
    elsif complete?
      "All requirements completed. Reviewed by #{@multipass.reviewers}."
    elsif !@multipass.testing
      "Waiting for CI to complete."
    else
      "Missing fields: #{@multipass.missing_fields.join(', ')}"
    end
  end
end
