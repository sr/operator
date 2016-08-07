require "bundler"

require "json"

require "lita"
require "lita/cli"
require "lita/handler"

require "replication_fixing/alerting_manager"
require "replication_fixing/datacenter_aware_registry"
require "replication_fixing/fixing_client"
require "replication_fixing/fixing_status_client"
require "replication_fixing/hostname"
require "replication_fixing/ignore_client"
require "replication_fixing/message_throttler"
require "replication_fixing/monitor_supervisor"
require "replication_fixing/pagerduty_pager"
require "replication_fixing/replication_error_sanitizer"
require "replication_fixing/shard"
require "replication_fixing/test_pager"


module Pardot
  module HAL
    def self.require_handlers
      require "pardot/hal/commit_handler"
      require "pardot/hal/replication_fixing_handler"
    end

    def self.start
      Lita::CLI.start
    end

    def self.register_handler(handler)
      Lita.register_handler(handler)
    end

    class Handler < Lita::Handler
    end
  end
end
