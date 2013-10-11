require "octokit"

Octokit.configure do |c|
  c.login = ENV['GITHUB_USER']
  c.password = ENV['GITHUB_PASSWORD']
end

