ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/application", __FILE__)

require "lita/rspec"
require "webmock/rspec"

WebMock.disable_net_connect!

Lita.config.redis[:host] = ENV.fetch("REDIS_HOST", "127.0.0.1")
Lita.config.redis[:port] = ENV.fetch("REDIS_PORT", "6379").to_i

Lita.version_3_compatibility_mode = false
HAL9000::Application.load_all
