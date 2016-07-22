class DeployACLEntry < ApplicationRecord
  ACL_TYPES = ["ldap_group"].freeze

  validates :project_id,
    presence: true,
    uniqueness: { scope: [:deploy_target_id] }
  validates :deploy_target_id, presence: true
  validates :acl_type,
    presence: true,
    inclusion: { in: ACL_TYPES }
  validates :value, presence: true

  serialize :value, JSON

  belongs_to :project
  belongs_to :deploy_target

  def self.for_project_and_deploy_target(project, deploy_target)
    where(project_id: project, deploy_target_id: deploy_target).first
  end

  def authorized?(user)
    case acl_type
    when "ldap_group"
      ldap_group_authorized?(user)
    else
      Instrumentation.error(at: "DeployACLEntry", fn: "authorized?", type: type)
      false
    end
  end

  private

  def ldap_group_authorized?(user)
    group_cns = value
    ldap_authorizer.user_is_member_of_any_group?(user.uid, group_cns)
  end

  def ldap_authorizer
    @ldap_authorized ||= Canoe::LDAPAuthorizer.new
  end
end
