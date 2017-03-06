# Checks if a user is the same as an actor using login and email.
module Multipass::ActorVerification
  def requested_by?(user)
    same_actor?(:requester, user)
  end

  def sre_approved_by?(user)
    same_actor?(:sre_approver, user)
  end

  def peer_reviewed_by?(user)
    same_actor?(:peer_reviewer, user)
  end

  def same_actor?(actor, user)
    send(actor) == user || send(actor) == User.for_github_login(user)
  end
end
