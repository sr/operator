require "json"
require "replication_fixing/ignore_client"
require "replication_fixing/fixing_status_client"
require "replication_fixing/fixing_client"
require "replication_fixing/pagerduty_pager"
require "replication_fixing/test_pager"
require "replication_fixing/hostname"

module Lita
  module Handlers
    class ReplicationFixing < Handler
      config :repfix_url, default: "https://repfix.tools.pardot.com"
      config :status_room, default: "1_ops@conf.btf.hipchat.com"
      config :pager, default: "pagerduty"
      config :pagerduty_service_key

      http.post "/replication/errors", :create_replication_error

      def initialize(robot)
        super

        @pager = \
          case config.pager.to_s
          when "pagerduty"
            ::ReplicationFixing::PagerdutyPager.new(config.pagerduty_service_key)
          when "test"
            ::ReplicationFixing::TestPager.new
          else
            raise ArgumentError, "unknown pager type: #{config.pager.to_s}"
          end

        @ignore_client = ::ReplicationFixing::IgnoreClient.new(redis)
        @fixing_status_client = ::ReplicationFixing::FixingStatusClient.new(redis)
        @fixing_client = ::ReplicationFixing::FixingClient.new(
          repfix_url: config.repfix_url,
          ignore_client: @ignore_client,
          fixing_status_client: @fixing_status_client,
          pager: @pager,
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

            result = @fixing_client.fix(hostname: hostname)
            case result
            when ::ReplicationFixing::FixingClient::NoErrorDetected
              log.debug("Got an error for #{hostname} but rep_fix reported no error when I checked")
              # TODO: Say something anyway, because that's what current Hal does
            when ::ReplicationFixing::FixingClient::ShardIsIgnored
              log.debug("Shard is ignored: #{hostname}")
            when ::ReplicationFixing::FixingClient::AllShardsIgnored
              log.debug("All shards are ignored")
              if (result.skipped_errors_count % 200).zero?
                # TODO: Notify PagerDuty
                robot.send_message(config.status_room, "@here FYI: Replication fixing has been stopped, but I've seen about #{result.skipped_errors_count} go by.")
              end
            when ::ReplicationFixing::FixingClient::NotFixable
              robot.send_message(config.status_room, "@all Replication is broken on #{hostname}, but I'm not able to fix it.")
            when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
              # TODO: Notify PagerDuty
              robot.send_message(config.status_room, "@all Got an error while trying to check the fixability of #{hostname}: #{result.error}")
            when ::ReplicationFixing::FixingClient::FixInProgress
              if result.new_fix
                robot.send_message(config.status_room, "Fixing replication on #{hostname}")
              elsif (Time.now - result.started_at) > 10 * 60
                robot.send_message(config.status_room, "@all I've been trying to fix replication on #{hostname} for #{(Time.now - result.started_at).to_i} minutes now")
                # TODO: Notify PagerDuty
              end
            else
              log.error("Got unknown response from client: #{result}")
            end

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

      Lita.register_handler(self)
    end
  end
end
