require "octokit"

Octokit.configure do |c|
  c.api_endpoint = "#{Project::GITHUB_URL}/api/v3"
  c.login = ENV['GITHUB_USER']
  c.password = ENV['GITHUB_PASSWORD']
end
