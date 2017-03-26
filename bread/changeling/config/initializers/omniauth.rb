hostname = Changeling.config.github_hostname

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,  Changeling.config.github_oauth_id, Changeling.config.github_oauth_secret, {
    scope: "user,repo:status",
    client_options: {
      :site => Changeling.config.github_api_endpoint,
      :authorize_url => "https://#{hostname}/login/oauth/authorize",
      :token_url => "https://#{hostname}/login/oauth/access_token",
    }
  }
end
