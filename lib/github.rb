require "octokit"

Octokit.configure do |c|
  c.api_endpoint = 'http://git.dev.pardot.com/api/v3'
  c.login = ENV['GITHUB_USER']
  c.password = ENV['GITHUB_PASSWORD']
end
