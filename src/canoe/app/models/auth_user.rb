class AuthUser < ApplicationRecord
  has_one :salesforce_authenticator_pairing

  def self.find_or_create_by_omniauth(auth_hash)
    find_or_initialize_by(uid: auth_hash["uid"]).tap do |user|
      # Mapping from LDAP: https://github.com/intridea/omniauth-ldap/blob/9d36cdb9f3d4da040ab6f7aff54450392b78f5eb/lib/omniauth/strategies/ldap.rb#L7-L21
      user.email = auth_hash["info"]["email"]
      user.name = [auth_hash["info"]["first_name"], auth_hash["info"]["last_name"]].compact.join(" ")
      user.save!
    end
  end

  def phone_paired?
    !salesforce_authenticator_pairing.nil?
  end

  def create_pairing(phrase)
    if phone_paired?
      raise RuntimeError, "phone already paired"
    end

    response = Canoe.salesforce_authenticator.create_pairing(email, phrase)

    if response.success?
      SalesforceAuthenticatorPairing.create!(auth_user_id: id, pairing_id: response["id"])
    end

    response
  end

  def deploy_authorized?(project, target)
    if !project
      raise ArgumentError, "invalid project: #{project.inspect}"
    end

    if !target
      raise ArgumentError, "invalid target: #{target.inspect}"
    end

    acl = DeployACLEntry.for_project_and_deploy_target(project, target)

    if !acl
      return true
    end

    if !acl.authorized?(self)
      event = {
        current_user: uid,
        project: project.name,
        target: target.name
      }
      Instrumentation.error("unauthorized-deploy", event)

      return false
    end

    true
  end
end
