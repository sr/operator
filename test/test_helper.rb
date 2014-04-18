# test_helper.rb
require "simplecov"
SimpleCov.start

CANOE_TEST_LOADED = true

CANOE_DIR=File.expand_path(File.join(File.dirname(__FILE__), ".."))
# add our root and lib dirs to the load path
$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"
$:.unshift "#{CANOE_DIR}/lib/helpers/"
$:.unshift "#{CANOE_DIR}/lib/models/"

ENV["RACK_ENV"] = "test"
ENV["API_AUTH_TOKEN"] = "chatty_rulez_123"

require "pp"
require "ostruct"
require "minitest/autorun"
require "minitest/pride"
require "mocha/setup"
require "rack/test"
require "app"

ActiveRecord::Base.logger.level = 1
# I18n.enforce_available_locales = false

def json_response
  JSON.parse(last_response.body)
end

def assert_nonerror_response
  assert last_response.ok?
  if json_response.keys.include?("error")
    pp json_response
    puts json_response["message"]
  end
  assert !json_response.keys.include?("error")
end

def assert_json_error_response(message_match="")
  assert last_response.ok?
  assert json_response["error"]
  assert_match message_match, json_response["message"]
end

def assert_redirect_to_login
  assert !last_response.ok?
  assert last_response.redirect?
  assert_match "/login", last_response.location
end

# ---------------------------------------------------------------------
def api_get(url)
  get url, { api_token: ENV["API_AUTH_TOKEN"], user_email: "sveader@salesforce.com" }, {}
end

def api_post(url)
  post url, { api_token: ENV["API_AUTH_TOKEN"], user_email: "sveader@salesforce.com" }, {}
end

def define_api_user_mock(email="sveader@salesforce.com")
  assoc_mock = mock
  assoc_mock.expects(:first).returns(AuthUser.new(id: 2, email: email))
  AuthUser.expects(:where).with(email: email).returns(assoc_mock)
end

def define_api_user_missing_mock(email="sveader@salesforce.com")
  assoc_mock = mock
  assoc_mock.expects(:first).returns(nil)
  AuthUser.expects(:where).with(email: email).returns(assoc_mock)
end

# ---------------------------------------------------------------------
def get_request_with_auth(url)
  get url, {}, "rack.session" => auth_session
end

def post_request_with_auth(url)
  post url, {}, "rack.session" => auth_session
end

def auth_session
  assoc_mock = mock
  assoc_mock.expects(:first).returns(AuthUser.new(id: 2))
  AuthUser.expects(:where).with(id: 2).returns(assoc_mock)
  { user_id: 2 } # returned
end

# ---------------------------------------------------------------------
def define_target_mock(&block)
  target_mock = DeployTarget.new(name: "test")
  assoc_mock = mock
  assoc_mock.stubs(:first).returns(target_mock)
  DeployTarget.stubs(:where).with(name: "test").returns(assoc_mock)

  yield(target_mock) if block_given?
end

def define_target_missing_mock(name)
  assoc_mock = mock
  assoc_mock.stubs(:first).returns(nil)
  DeployTarget.stubs(:where).with(name: name).returns(assoc_mock)
end

def define_repo_mock(repo_name="pardot", &block)
  Octokit.expects(:repo).with("pardot/#{repo_name}").returns(OpenStruct.new)
end
