require "octokit"

Octokit.configure do |c|
  c.api_endpoint = Canoe.config.github_api_endpoint
  c.login = Canoe.config.github_user
  c.password = Canoe.config.github_password
  c.connection_options = {
    request: {
      open_timeout: ENV.fetch("GITHUB_OPEN_TIMEOUT", "3").to_i,
      timeout: ENV.fetch("GITHUB_TIMEOUT", "10").to_i
    }
  }
end
