require "octokit"

Octokit.configure do |c|
  c.api_endpoint = 'https://git.dev.pardot.com/api/v3'
  c.login = ENV.fetch('GITHUB_USER')
  c.password = ENV.fetch('GITHUB_PASSWORD')
end
