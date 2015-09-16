# test_helper.rb
require "simplecov"
SimpleCov.start

SYNC_SCRIPTS_DIR=File.expand_path(File.join(File.dirname(__FILE__), ".."))
# add our root and lib dirs to the load path
$:.unshift SYNC_SCRIPTS_DIR
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/helpers/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/core_ext/"

require "minitest/autorun"
require "minitest/pride"
require "mocha/setup"
require "ostruct"
require "pp"
require "webmock/minitest"

WebMock.disable_net_connect!
