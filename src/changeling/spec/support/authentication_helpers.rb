module AuthenticationHelpers
  def http_basic_auth
    username = ENV["HTTP_BASIC_USERNAME"]
    password = ENV["HTTP_BASIC_PASSWORD"]
    encoded = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

    { "HTTP_AUTHORIZATION" => encoded }
  end

  def login_with_oauth(username = "joe")
    body = [{ login: "heroku" }].to_json
    stub_json_request(:get, "https://api.github.com/user/orgs", body)
    visit "/auth/github"
    expect(page).to have_content(username)

    username
  end

  def auth_as_herokai(user)
    mock_auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      credentials: {
        token: "abc123"
      },
      extra: {
        raw_info: {
          login: user
        }
      }
    )
    OmniAuth.config.mock_auth[:github] = mock_auth

    allow(User).to receive(:"require_herokai!").and_return(true)

    get "/auth/github"
    follow_redirect!
  end
end
