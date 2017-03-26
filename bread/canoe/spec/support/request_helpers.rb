module RequestHelpers
  def stub_authentication(user)
    OmniAuth.config.mock_auth[:developer] = {
      "info" => { "email" => user.email }
    }
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:developer]
  end

  def perform_login
    post "/auth/developer/callback" # login
  end
end
