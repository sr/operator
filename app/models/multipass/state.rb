# Handle what the state of a multipass is
module Multipass::State
  def update_complete
    self.complete = complete?
    true
  end

  def complete?
    return true if emergency_approver
    missing_fields.empty?
  end

  def rejected?
    return true if rejector
    false
  end

  def pending?
    !complete? && !merged
  end

  def peer_reviewed?
    peer_reviewer.present?
  end

  def user_is_peer_reviewer?(user)
    peer_reviewed? && peer_reviewer == user
  end

  def sre_approved?
    sre_approver.present?
  end

  def user_is_sre_approver?(user)
    sre_approved? && sre_approver == user
  end

  def emergency_approved?
    emergency_approver.present?
  end

  def user_is_emergency_approver?(user)
    emergency_approved? && emergency_approver == user
  end

  def user_is_rejector?(user)
    rejected? && rejector == user
  end

  def status
    if complete?
      "complete"
    elsif pending?
      "pending"
    elsif rejected?
      "rejected"
    else
      "incomplete"
    end
  end

  def changed_risk_assessment?
    return false if audits.size == 1
    audits.any? do |audit|
      audit.audited_changes["impact"] != "low"
    end
  end
end
