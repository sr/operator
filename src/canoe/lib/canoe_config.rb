class CanoeConfig
  def phone_authentication_required?
    return @phone_authentication_required if defined?(@phone_authentication_required)
    @phone_authentication_required = !ENV["CANOE_2FA_REQUIRED"].to_s.empty?
  end
  attr_writer :phone_authentication_required

  def salesforce_authenticator_consumer_id
    ENV.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_ID")
  end

  def salesforce_authenticator_consumer_key
    ENV.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_KEY")
  end
end
