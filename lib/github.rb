require "octokit"

Octokit.configure do |c|
  c.api_endpoint = 'https://git.dev.pardot.com/api/v3'
  c.faraday_config = { ssl: { verify: false } }
  c.login = ENV['GITHUB_USER']
  c.password = ENV['GITHUB_PASSWORD']
end
