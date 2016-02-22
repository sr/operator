require "json"
require "replication_fixing/alerting_manager"
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

module Lita
  module Handlers
    class ReplicationFixing < Handler
      config :repfix_url, default: "https://repfix.pardot.com"
      config :status_room, default: "1_ops@conf.btf.hipchat.com"
      config :replication_room, default: "1_ops-replication@conf.btf.hipchat.com"
      config :monitor_only, default: true
      config :pager, default: "pagerduty"
      config :pagerduty_service_key

      http.get "/replication/_ping", :ping
      http.post "/replication/errors", :create_replication_error

      # http://rubular.com/r/Gz3fLQiR5L
      route /ignore\s+(?<shard_id>\d+)(?:\s+(?:(?<prefix>db|whoisdb)|(?<minutes>\d+))(?:\s+(?<minutes>\d+))?)?/i, :create_ignore, help: {
        "ignore SHARD_ID" => "Ignores db-SHARD_ID for 10 minutes",
        "ignore SHARD_ID PREFIX" => "Ignores PREFIX-SHARD_ID for 10 minutes (PREFIX is, e.g., db or whoisdb)",
        "ignore SHARD_ID MINUTES" => "Ignores db-SHARD_ID for MINUTES minutes",
        "ignore SHARD_ID PREFIX MINUTES" => "Ignores PREFIX-SHARD_ID for MINUTES minutes",
      }

      route /fix\s+(?<shard_id>\d+)(?:\s+(?<prefix>db|whoisdb))?/i, :create_fix, help: {
        "fix SHARD_ID" => "Attempts to fix db-SHARD_ID",
        "fix SHARD_ID PREFIX" => "Attempts to fix PREFIX-SHARD_ID (PREFIX is, e.g., db or whoisdb)",
      }

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
          fixing_status_client: @fixing_status_client,
          log: log,
        )
        @monitor_supervisor = ::ReplicationFixing::MonitorSupervisor.new(fixing_client: @fixing_client)

        @status_room = ::Lita::Source.new(room: config.status_room)
        @replication_room = ::Lita::Source.new(room: config.replication_room)
      end

      on(:connected) do
        robot.join(config.status_room)
        robot.join(config.replication_room)
      end

      def ping(request, response)
        response.status = 200
        response.body << ""
      end

      def create_replication_error(request, response)
        body = request.POST
        if body["hostname"]
          begin
            hostname = ::ReplicationFixing::Hostname.new(body["hostname"])
            shard = hostname.shard

            ignoring = @ignore_client.ignoring?(shard.prefix, shard.id)
            if ignoring
              log.debug("Shard is ignored: #{shard}")

              count = @ignore_client.incr_skipped_errors_count
              if (count % 200).zero?
                @throttler.send_message(@status_room, "@here FYI: Replication fixing has been stopped, but I've seen about #{result.skipped_errors_count} go by.")
                @alerting_manager.notify_replication_disabled_but_many_errors
              end
            else
              @throttler.send_message(@replication_room, "#{hostname}: #{body["error"]}") if body["error"]

              if mysql_last_error = body["mysql_last_error"]
                sanitized_error = @sanitizer.sanitize(mysql_last_error)
                @throttler.send_message(@replication_room, "#{hostname}: #{sanitized_error}")
              end

              result = \
                if config.monitor_only
                  @fixing_client.host_status(hostname: hostname)
                else
                  @alerting_manager.ingest_fix_result(shard_or_hostname: hostname, result: result)
                  @fixing_client.fix_host(hostname: hostname)
                end

              reply_with_fix_result(shard_or_hostname: hostname, result: result)
              ensure_monitoring(shard: hostname.shard)
            end

            response.status = 201
          rescue ::ReplicationFixing::Hostname::MalformedHostname
            response.status = 400
            response.body << JSON.dump("error" => "malformed hostname")
          end
        else
          response.status = 400
          response.body << JSON.dump("error" => "hostname missing")
        end
      end

      def create_ignore(response)
        shard_id = response.match_data["shard_id"].to_i
        prefix = response.match_data["prefix"] || "db"
        minutes = (response.match_data["minutes"] || "10").to_i

        @ignore_client.ignore(prefix, shard_id)
        response.reply("I will ignore #{prefix}-#{shard_id} for #{minutes} minutes")
      end

      def create_fix(response)
        if config.monitor_only
          return
        end

        shard_id = response.match_data["shard_id"].to_i
        prefix = response.match_data["prefix"] || "db"
        shard = ::ReplicationFixing::Shard.new(prefix, shard_id)

        result = @fixing_client.fix_shard(shard: shard)

        case result
        when ::ReplicationFixing::FixingClient::NoErrorDetected
          response.reply "No errors detected on #{shard}"
        when ::ReplicationFixing::FixingClient::NotFixable
          response.reply "Sorry, I'm not able to fix #{shard} right now. I need a human to resolve it."
        when ::ReplicationFixing::FixingClient::FixInProgress
          ongoing_minutes = ((Time.now - result.started_at) / 60.0).to_i
          if ongoing_minutes <= 0
            response.reply "OK, I'm trying to fix #{shard}"
          else
            response.reply "I've been trying to fix #{shard} for #{ongoing_minutes.to_i} minutes now"
          end
        when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
          response.reply "I got an error while checking fixability: #{result.error}"
        else
          response.reply "Uh, I got an unknown result: #{result}"
        end

        ensure_monitoring(shard: shard)
      end

      private
      def reply_with_fix_result(shard_or_hostname:, result:)
        case result
        when ::ReplicationFixing::FixingClient::NoErrorDetected
          @throttler.send_message(@status_room, "(successful) Replication is fixed on #{shard_or_hostname}")
        when ::ReplicationFixing::FixingClient::NotFixable
          @throttler.send_message(@status_room, "@all Replication is broken on #{shard_or_hostname}, but I'm not able to fix it")
        when ::ReplicationFixing::FixingClient::FixInProgress
          ongoing_minutes = (Time.now - result.started_at) / 60.0
          if ongoing_minutes >= 10.0
            @alerting_manager.notify_fixing_a_long_while(shard_or_hostname: shard_or_hostname, started_at: result.started_at)
            @throttler.send_message(@status_room, "@all I've been trying to fix replication on #{shard_or_hostname} for #{ongoing_minutes.to_i} minutes now")
          else
            @throttler.send_message(@status_room, "/me is fixing replication on #{shard_or_hostname} (ongoing for #{ongoing_minutes.to_i} minutes)")
          end
        when ::ReplicationFixing::FixingClient::FixableErrorOccurring
          @throttler.send_message(@status_room, "/me is noticing a fixable replication error on #{shard_or_hostname}")
        when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
          @throttler.send_message(@status_room, "/me is getting an error while trying to check the fixability of #{shard_or_hostname}: #{result.error}")
        else
          log.error("Got unknown response from client: #{result}")
        end
      end

      def ensure_monitoring(shard:)
        monitor = ::ReplicationFixing::Monitor.new(shard: shard, tick: 30)
        monitor.on_tick { |result| reply_with_fix_result(shard_or_hostname: shard, result: result) }

        @monitor_supervisor.start_exclusive_monitor(monitor)
      end

      Lita.register_handler(self)
    end
  end
end
