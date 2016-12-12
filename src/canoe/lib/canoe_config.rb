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
    @env.fetch("GITHUB_PASSWORD")
  end

  def github_url
    @env.fetch("GITHUB_URL", "https://git.dev.pardot.com")
  end
end
