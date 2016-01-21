class DeployACLEntry < ActiveRecord::Base
  ACL_TYPES = ["ldap_group"]

  validates :repo_id,
    presence: true,
    uniqueness: {scope: [:deploy_target_id]}
  validates :deploy_target_id, presence: true
  validates :acl_type,
    presence: true,
    inclusion: {in: ACL_TYPES}
  validates :value, presence: true

  serialize :value, JSON

  belongs_to :repo
  belongs_to :deploy_target

  def self.for_repo_and_deploy_target(repo, deploy_target)
    where(repo_id: repo, deploy_target_id: deploy_target).first
  end

  def authorized?(user)
    case acl_type
    when "ldap_group"
      ldap_group_authorized?(user)
    else
      Rails.logger.error "Unknown ACL type: #{type}"
      false
    end
  end

  private
  def ldap_group_authorized?(user)
    group_cns = self.value
    ldap_authorizer.user_is_member_of_any_group?(user.uid, group_cns)
  end

  def ldap_authorizer
    @ldap_authorized ||= Canoe::LDAPAuthorizer.new
  end
end
