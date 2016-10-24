class SalesforceAuthenticatorPairing < ActiveRecord::Base
  class Error < StandardError
  end

  belongs_to :auth_user

  def authenticate
    if pairing_id.nil?
      return false
    end

    auth = Canoe.salesforce_authenticator.initiate_authentication(pairing_id)

    if !auth.success?
      return false
    end

    max_tries = 13
    tries = 0

    until tries >= max_tries
      response = Canoe.salesforce_authenticator.authentication_status(auth["id"])

      if response["granted"]
        return true
      end

      tries += 1
      sleep 2
    end
  end

  def create_pairing(phrase)
    if paired?
      raise Error, "phone already paired"
    end

    response = Canoe.salesforce_authenticator.create_pairing(auth_user.email, phrase)

    if !response.success?
      return response
    end

    update!(pairing_id: response["id"])

    response
  end


  def pairing_in_progress?
    if pairing_id.nil?
      return false
    end

    response = Canoe.salesforce_authenticator.pairing_status(pairing_id)

    if !response.success?
      return false
    end

    response["pending"]
  end

  def paired?
    if pairing_id.nil?
      return false
    end

    response = Canoe.salesforce_authenticator.pairing_status(pairing_id)

    if !response.success? || !response["enabled"] || response["deactivated"]
      return false
    end

    true
  end
end
