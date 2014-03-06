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
unless defined?(CanoeApplication)
  require "app"
end

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
