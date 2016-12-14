class CanoeConfig
  def initialize(env)
    @env = env
  end

  def chef_repository_name
    "Pardot/chef"
  end

  def github_client
    return @github_client if defined?(@github_client)
    @github_client = Octokit::Client.new(
      api_endpoint: github_api_endpoint,
      access_token: github_password
    )
  end
  attr_writer :github_client

  def github_api_endpoint
    "#{github_url}/api/v3"
  end

  def github_user
    @env.fetch("GITHUB_USER", "sa-canoe")
  end

  def github_password
    @env.fetch("GITHUB_PASSWORD", "")
  end

  def github_url
    @env.fetch("GITHUB_URL", "https://git.dev.pardot.com")
  end

  def phone_authentication_required?
    return @phone_authentication_required if defined?(@phone_authentication_required)
    @phone_authentication_required = !@env["CANOE_2FA_REQUIRED"].to_s.empty?
  end
  attr_writer :phone_authentication_required

  def phone_authentication_max_tries
    return @phone_authentication_max_tries if defined?(@phone_authentication_max_tries)
    @phone_authentication_max_tries = Integer(@env.fetch("CANOE_PHONE_AUTHENTICATION_MAX_TRIES", 13))
  end
  attr_writer :phone_authentication_max_tries

  def phone_authentication_sleep_interval
    return @phone_authentication_sleep_interval if defined?(@phone_authentication_sleep_interval)
    @phone_authentication_sleep_interval = Integer(@env.fetch("PHONE_AUTHENTICATION_SLEEP_INTERVAL", 2))
  end
  attr_writer :phone_authentication_sleep_interval

  def salesforce_authenticator_consumer_id
    @env.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_ID", "")
  end

  def salesforce_authenticator_consumer_key
    @env.fetch("SALESFORCE_AUTHENTICATOR_CONSUMER_KEY", "")
  end
end
