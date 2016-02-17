require "json"
require "replication_fixing/alerting_manager"
require "replication_fixing/fixing_client"
require "replication_fixing/fixing_status_client"
require "replication_fixing/hostname"
require "replication_fixing/ignore_client"
require "replication_fixing/message_throttler"
require "replication_fixing/pagerduty_pager"
require "replication_fixing/replication_error_sanitizer"
require "replication_fixing/test_pager"

module Lita
  module Handlers
    class ReplicationFixing < Handler
      config :repfix_url, default: "https://repfix.tools.pardot.com"
      config :status_room, default: "1_ops@conf.btf.hipchat.com"
      config :replication_room, default: "1_ops-replication@conf.btf.hipchat.com"
      config :monitor_only, default: true
      config :pager, default: "pagerduty"
      config :pagerduty_service_key

      http.post "/replication/errors", :create_replication_error

      def initialize(robot)
        super

        @throttler = ::ReplicationFixing::MessageThrottler.new(robot: robot)
        @sanitizer = ::ReplicationFixing::ReplicationErrorSanitizer.new

        @pager = \
          case config.pager.to_s
          when "pagerduty"
            ::ReplicationFixing::PagerdutyPager.new(config.pagerduty_service_key)
          when "test"
            ::ReplicationFixing::TestPager.new
          else
            raise ArgumentError, "unknown pager type: #{config.pager.to_s}"
          end

        @alerting_manager = ::ReplicationFixing::AlertingManager.new(
          pager: @pager,
          log: log,
        )

        @ignore_client = ::ReplicationFixing::IgnoreClient.new(redis)
        @fixing_status_client = ::ReplicationFixing::FixingStatusClient.new(redis)
        @fixing_client = ::ReplicationFixing::FixingClient.new(
          repfix_url: config.repfix_url,
          ignore_client: @ignore_client,
          fixing_status_client: @fixing_status_client,
          log: log,
        )
      end

      on(:connected) do
        robot.join(config.status_room)
      end

      def create_replication_error(request, response)
        json = JSON.parse(request.body.string)
        if json["mysql_last_error"] && json["hostname"]
          begin
            hostname = ::ReplicationFixing::Hostname.new(json["hostname"])

            sanitized_error = @sanitizer.sanitize(json["mysql_last_error"])
            @throttler.send_message(config.replication_room, "#{hostname}: #{sanitized_error}")

            result = @fixing_client.fix(hostname: hostname)
            @alerting_manager.ingest_fix_result(hostname: hostname, result: result)
            reply_with_fix_result(hostname: hostname, result: result)

            response.status = 201
          rescue ::ReplicationFixing::Hostname::MalformedHostname
            response.status = 400
            response.body << JSON.dump("error" => "malformed hostname")
          end
        else
          response.status = 400
          response.body << JSON.dump("error" => "mysql_last_error or hostname missing")
        end
      end

      private
      def reply_with_fix_result(hostname:, result:)
        case result
        when ::ReplicationFixing::FixingClient::NoErrorDetected
          log.debug("Got an error for #{hostname} but rep_fix reported no replication error when I checked")
        when ::ReplicationFixing::FixingClient::ShardIsIgnored
          log.debug("Shard is ignored: #{hostname}")
        when ::ReplicationFixing::FixingClient::AllShardsIgnored
          log.debug("All shards are ignored")
          if (result.skipped_errors_count % 200).zero?
            @throttler.send_message(config.status_room, "@here FYI: Replication fixing has been stopped, but I've seen about #{result.skipped_errors_count} go by.")
          end
        when ::ReplicationFixing::FixingClient::NotFixable
          @throttler.send_message(config.status_room, "@all Replication is broken on #{hostname}, but I'm not able to fix it.")
        when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
          @throttler.send_message(config.status_room, "@all Got an error while trying to check the fixability of #{hostname}: #{result.error}")
        when ::ReplicationFixing::FixingClient::FixInProgress
          if result.new_fix
            @throttler.send_message(config.status_room, "/me is fixing replication on #{hostname}")
          elsif (Time.now - result.started_at) > 10 * 60
            @alerting_manager.notify_fixing_a_long_while(hostname: hostname, started_at: result.started_at)
            @throttler.send_message(config.status_room, "@all I've been trying to fix replication on #{hostname} for #{(Time.now - result.started_at).to_i} minutes now")
          else
            @throttler.send_message(config.status_room, "/me still fixing replication on #{hostname}")
          end
        else
          log.error("Got unknown response from client: #{result}")
        end
      end

      Lita.register_handler(self)
    end
  end
end
