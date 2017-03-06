# Multipass validator for sre_approver is in github team
class SREApproverIsInSRE < ActiveModel::Validator
  def validate(multipass)
    return if !multipass.sre_approver_changed? || multipass.sre_approver.blank?
    approvers = SREApprover.all.map(&:github_login)
    return if approvers.map(&:downcase).include?(multipass.sre_approver.downcase)
    multipass.errors.add(:sre_approver, "must be in the GitHub SRE Approvers team")
  end
end
