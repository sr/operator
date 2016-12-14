require "octokit"

Octokit.configure do |c|
  c.api_endpoint = Canoe.config.github_api_endpoint
  c.login = Canoe.config.github_user
  c.password = Canoe.config.github_password
end
