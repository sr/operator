# Handle actions users can do on a multipass
module Multipass::Actions
  def review(user)
    if peer_reviewed?
      errors.add(:peer_reviewer, "is already set")
      return false
    end

    self.peer_reviewer = user
    save
    return false if errors.any?
    ActiveSupport::Notifications.instrument("multipass.peer_review", from: "form")
    true
  end

  def remove_review(user)
    unless peer_reviewed?
      errors.add(:peer_reviewer, "is not set")
      return false
    end

    unless user_is_peer_reviewer?(user)
      errors.add(:peer_reviewer, "can only be unset by #{peer_reviewer}")
      return false
    end

    self.peer_reviewer = nil
    save
  end

  def sre_approve(user)
    if sre_approved?
      errors.add(:sre_approver, "is already set")
      return false
    end

    self.sre_approver = user
    save
  end

  def remove_sre_approval(user)
    unless sre_approved?
      errors.add(:sre_approver, "is not set")
      return false
    end

    unless user_is_sre_approver?(user)
      errors.add(:sre_approver, "can only be unset by #{sre_approver}")
      return false
    end

    self.sre_approver = nil
    save
  end

  def emergency_approve(user)
    if emergency_approved?
      errors.add(:emergency_approver, "is already set")
      return false
    end

    self.emergency_approver = user
    saved = save
    ActiveSupport::Notifications.instrument("multipass.emergency_override", multipass: self)
    saved
  end

  def unset_emergency_approver(user)
    unless emergency_approved?
      errors.add(:emergency_approver, "is not set")
      return false
    end

    unless user_is_emergency_approver?(user)
      errors.add(:emergency_approver, "can only be unset by #{emergency_approver}")
      return false
    end

    self.emergency_approver = nil
    save
  end

  def reject(user)
    if rejected?
      errors.add(:rejector, "is already set")
      return false
    end

    self.rejector = user
    save
  end

  def reopen(user)
    unless rejected?
      errors.add(:rejector, "is not set")
      return false
    end

    unless user_is_rejector?(user)
      errors.add(:rejector, "can only be unset by #{rejector}")
      return false
    end

    self.rejector = nil
    save
  end
end
