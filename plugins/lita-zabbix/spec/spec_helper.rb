require "lita-zabbix"
require "lita/rspec"
require "webmock/rspec"

WebMock.disable_net_connect!

Lita.config.redis[:host] = ENV.fetch("REDIS_HOST", "127.0.0.1")
Lita.config.redis[:port] = ENV.fetch("REDIS_PORT", "6379").to_i

require_relative "helpers/zabbix_test_helpers"

# A compatibility mode is provided for older plugins upgrading from Lita 3. Since this plugin
# was generated with Lita 4, the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false
