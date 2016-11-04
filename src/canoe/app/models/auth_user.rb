class AuthUser < ApplicationRecord
  DEFAULT_MAX_AUTH_TRIES = 13
  DEFAULT_MAX_AUTH_SLEEP_INTERVAL = 2
  DEFAULT_2FA_ACTION = "Pardot T&P 2FA".freeze

  has_one :salesforce_authenticator_pairing

  def self.find_or_create_by_omniauth(auth_hash)
    find_or_initialize_by(uid: auth_hash["uid"]).tap do |user|
      # Mapping from LDAP: https://github.com/intridea/omniauth-ldap/blob/9d36cdb9f3d4da040ab6f7aff54450392b78f5eb/lib/omniauth/strategies/ldap.rb#L7-L21
      user.email = auth_hash["info"]["email"]
      user.name = [auth_hash["info"]["first_name"], auth_hash["info"]["last_name"]].compact.join(" ")
      user.save!
    end
  end

  def phone
    salesforce_authenticator_pairing ||
      SalesforceAuthenticatorPairing.new(auth_user_id: id)
  end

  def authenticate_phone(options = {})
    max_tries = Integer(options[:max_tries] || DEFAULT_MAX_AUTH_TRIES)
    sleep_interval = Integer(options[:sleep_interval] || DEFAULT_MAX_AUTH_SLEEP_INTERVAL)
    action = options[:action] || DEFAULT_2FA_ACTION

    if !phone.paired?
      return false
    end

    auth = Canoe.salesforce_authenticator.initiate_authentication(phone.pairing_id, action: action)

    if !auth.success?
      return false
    end

    tries = 0

    until tries >= max_tries
      response = Canoe.salesforce_authenticator.authentication_status(auth["id"])

      if response["granted"]
        return true
      end

      tries += 1
      sleep(sleep_interval)
    end

    false
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
