# test_helper.rb
require "simplecov"
SimpleCov.start

SYNC_SCRIPTS_DIR=File.expand_path(File.join(File.dirname(__FILE__), ".."))
$:.unshift SYNC_SCRIPTS_DIR

require "minitest/autorun"
require "minitest/pride"
require "mocha/setup"
require "ostruct"
require "pp"
require "webmock/minitest"

WebMock.disable_net_connect!
