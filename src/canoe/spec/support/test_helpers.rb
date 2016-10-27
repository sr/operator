module TestHelpers
  def json_response
    return @json_response if defined?(@json_response)
    @json_response = JSON.parse(response.body)
  end

  def assert_nonerror_response
    expect(response).to be_ok
    if json_response.keys.include?("error")
      pp json_response
      puts json_response["message"]
    end
    expect(json_response.keys).not_to include("error")
  end

  def assert_json_error_response(message_match = //)
    expect(response).not_to be_ok
    expect(json_response["error"]).to be_truthy
    expect(json_response["message"]).to match(message_match)
  end

  def assert_redirect_to_login
    expect(!response.ok?).to be_truthy
    expect(response.redirect?).to be_truthy
    expect(response.location).to match(%r{/login$})
  end

  # ---------------------------------------------------------------------
  def api_get(url)
    get url, params: { user_email: "sveader@salesforce.com" }, env: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  def api_post(url, params = {})
    post url, params: { api_token: ENV["API_AUTH_TOKEN"], user_email: "sveader@salesforce.com" }.merge(params), env: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  def api_put(url, params = {})
    put url, params: { user_email: "sveader@salesforce.com" }.merge(params), env: { "HTTP_X_API_TOKEN" => ENV["API_AUTH_TOKEN"] }
  end

  # ---------------------------------------------------------------------
  def get_request_with_auth(url)
    get url, {}, "rack.session" => auth_session
  end

  def post_request_with_auth(url)
    post url, {}, "rack.session" => auth_session
  end

  def auth_session
    assoc_mock = double
    expect(assoc_mock).to receive(:first).and_return(AuthUser.new(id: 2))
    expect(AuthUser).to recieve(:where).with(id: 2).and_return(assoc_mock)
    { user_id: 2 } # returned
  end

  def define_deploy_mock(id)
    deploy_mock = Deploy.new(id: id)
    allow(Deploy).to receive(:find_by_id).with(id).and_return(deploy_mock)

    yield(deploy_mock) if block_given?
  end
end
