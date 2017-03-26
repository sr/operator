class SalesforceAuthenticatorPairing < ActiveRecord::Base
  class Error < StandardError
  end

  belongs_to :auth_user

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
