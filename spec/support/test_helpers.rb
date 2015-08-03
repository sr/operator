module TestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def assert_nonerror_response
    expect(response).to be_ok
    if json_response.keys.include?("error")
      pp json_response
      puts json_response["message"]
    end
    expect(json_response.keys).not_to include("error")
  end

  def assert_json_error_response(message_match=//)
    expect(response).to be_ok
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
    get url, { api_token: ENV["API_AUTH_TOKEN"], user_email: "sveader@salesforce.com" }, {}
  end

  def api_post(url, params={})
    post url, { api_token: ENV["API_AUTH_TOKEN"], user_email: "sveader@salesforce.com" }.merge(params), {}
  end

  def define_api_user_mock(email="sveader@salesforce.com")
    expect(AuthUser).to receive(:find_by_email).with(email).and_return(AuthUser.new(id: 2, email: email))
  end

  def define_api_user_missing_mock(email="sveader@salesforce.com")
    expect(AuthUser).to receive(:find_by_email).with(email).and_return(nil)
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

  # ---------------------------------------------------------------------
  def define_target_mock(&block)
    target_mock = DeployTarget.new(name: "test")
    assoc_mock = double
    allow(assoc_mock).to receive(:first).and_return(target_mock)
    allow(DeployTarget).to receive(:where).with(name: "test").and_return(assoc_mock)

    yield(target_mock) if block_given?
  end

  def define_target_missing_mock(name)
    assoc_mock = double
    allow(assoc_mock).to receive(:first).and_return(nil)
    allow(DeployTarget).to receive(:where).with(name: name).and_return(assoc_mock)
  end

  def define_deploy_mock(id, &block)
    deploy_mock = Deploy.new(id: id)
    allow(Deploy).to receive(:find_by_id).with(id).and_return(deploy_mock)

    yield(deploy_mock) if block_given?
  end

  def define_repo_mock(repo_name="pardot", &block)
    repo = OpenStruct.new(full_name: "pardot/#{repo_name}", name: repo_name)
    expect(Octokit).to receive(:repo).with("pardot/#{repo_name}").and_return(repo)
  end
end
