class ComplianceStatus
  def initialize(multipass)
    @multipass = multipass
  end

  def update_complete
    @multipass.complete = complete?
    true
  end

  def complete?
    adapter.complete?
  end

  def rejected?
    adapter.rejected?
  end

  def pending?
    adapter.pending?
  end

  def peer_reviewed?
    adapter.peer_reviewed?
  end

  def user_is_peer_reviewer?(user)
    peer_reviewed? && adapter.user_is_peer_reviewer?(user)
  end

  def sre_approved?
    adapter.sre_approved?
  end

  def user_is_sre_approver?(user)
    sre_approved? && adapter.user_is_sre_approver?(user)
  end

  def emergency_approved?
    adapter.emergency_approved?
  end

  def user_is_emergency_approver?(user)
    emergency_approved? && adapter.user_is_emergency_approver?(user)
  end

  def user_is_rejector?(user)
    rejected? && adapter.user_is_rejector?(user)
  end

  def github_commit_status_description
    adapter.github_commit_status_description
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

  private

  def adapter
    @adapter ||=
      if Changeling.config.pardot?
        PardotComplianceStatus.new(@multipass)
      else
        HerokuComplianceStatus.new(@multipass)
      end
  end
end
