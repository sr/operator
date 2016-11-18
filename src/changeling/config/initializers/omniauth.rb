Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_OAUTH_ID'], ENV['GITHUB_OAUTH_SECRET'], scope: "user,repo:status"
end
