require "octokit"

Octokit.configure do |c|
  c.api_endpoint = 'https://git.dev.pardot.com/api/v3'
  c.faraday_config do |f|
    f.instance_variable_set(:@ssl, { verify: false })
  end
  c.login = ENV['GITHUB_USER']
  c.password = ENV['GITHUB_PASSWORD']
end
