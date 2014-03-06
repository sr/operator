# test_helper.rb
require "cover_me"

CANOE_DIR=File.expand_path(File.join(File.dirname(__FILE__), ".."))
# add our root and lib dirs to the load path
$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"
$:.unshift "#{CANOE_DIR}/lib/helpers/"
$:.unshift "#{CANOE_DIR}/lib/models/"

ENV["RACK_ENV"] = "test"

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

def assert_redirect_to_login
  assert !last_response.ok?
  assert last_response.redirect?
  assert_match "/login", last_response.location
end

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
