class CanoeConfig
  def phone_authentication_required?
    return @phone_authentication_required if defined?(@phone_authentication_required)
    @phone_authentication_required = !ENV["CANOE_2FA_REQUIRED"].to_s.empty?
  end
  attr_writer :phone_authentication_required

  def phone_authentication_max_tries
    return @phone_authentication_max_tries if defined?(@phone_authentication_max_tries)
    @phone_authentication_max_tries = Integer(ENV.fetch("CANOE_PHONE_AUTHENTICATION_MAX_TRIES", 13))
  end
  attr_writer :phone_authentication_max_tries

  def phone_authentication_sleep_interval
    return @phone_authentication_sleep_interval if defined?(@phone_authentication_sleep_interval)
    @phone_authentication_sleep_interval = Integer(ENV.fetch("PHONE_AUTHENTICATION_SLEEP_INTERVAL", 2))
  end
  attr_writer :phone_authentication_sleep_interval

  def salesforce_authenticator_consumer_id
    ENV.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_ID", "")
  end

  def salesforce_authenticator_consumer_key
    ENV.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_KEY", "")
  end
end
