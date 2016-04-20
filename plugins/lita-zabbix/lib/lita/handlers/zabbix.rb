require "zabbixapi"
require "zabbix/maintenance_supervisor"
require "zabbix/client"
require "zabbix/zabbixmon"
require "zabbix/monitor_supervisor"
require "zabbix/pagerduty_pager"
require "zabbix/test_pager"
require "human_time"

module Lita
  module Handlers
    class Zabbix < Handler

      MonitorNotFound = Class.new(StandardError)
      MonitorPauseFailed = Class.new(StandardError)
      MonitorUnpauseFailed = Class.new(StandardError)
      MonitorDataInsertionFailed = Class.new(StandardError)
      MonitoringFailure = Class.new(StandardError)
      MONITOR_FAIL_ERRMSG = '::Lita::Handlers::Zabbix::run_monitors has failed, triggering its rescue clause'
      PagerFailed = Class.new(StandardError)

      # config: zabbix
      config :zabbix_url, default: "https://zabbix-%datacenter%.pardot.com/api_jsonrpc.php"
      config :zabbix_hostname, default: 'zabbix-%datacenter%.pardot.com'
      config :zabbix_user, default: "Admin"
      config :zabbix_password, required: "changeme"

      # config: datacenters
      config :datacenters, default: ['dfw']
      config :default_datacenter, default: 'dfw'

      # config: hal9000's "home room"
      config :status_room, default: '1_ops@conf.btf.hipchat.com'

      # config: zabbix monitor
      config :monitor_debug_out_targets, default: ["1_261@chat.btf.hipchat.com"]
      config :monitor_hipchat_notify, default: false
      config :monitor_interval_seconds, default: 60
      config :monitor_retries, default: 5
      config :monitor_retry_interval_seconds, default: 5
      config :monitor_http_timeout_seconds, default: 30
      config :active_monitors, default: [::Zabbix::Zabbixmon::MONITOR_NAME], type: Array
      config :paging_monitors, default: []

      # config: page-r-doodie
      config :pager, default: 'test'
      config :pagerduty_service_key

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
        "zabbix maintenance start HOST" => "Puts hosts matching HOST in maintenance mode for 1 hour",
        "zabbix maintenance start HOST until=24h" => "Puts hosts matching HOST in maintenance mode for 24 hours",
      }

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
        "zabbix maintenance stop HOST" => "Brings hosts matching HOST out of maintenance mode",
      }

      route /^zabbix monitor (?<datacenter>\S+)\s+pause(?:\s+(?<options>.*))?$/i, :pause_monitor, command: true, help: {
        "zabbix monitor <datacenter> pause" => "Pauses the zabbix monitor for <datacenter> for 1 hour",
        "zabbix monitor <datacenter> pause until=24h" => "Pauses the zabbix monitor for <datacenter> for 24 hours",
      }

      route /^zabbix monitor (?<datacenter>\S+)\s+unpause(?:\s+(?<options>.*))?$/i, :unpause_monitor, command: true, help: {
        "zabbix monitor <datacenter> unpause" => "Unpauses <datacenter>s zabbix monitor",
      }

      route /^zabbix monitor status$/i, :monitor_status, command:true,  help: {
        "zabbix monitor status" => "Provides zabbix monitor status",
      }

      route /^zabbix monitor info$/i, :monitor_info, command:true,  help: {
        "zabbix monitor info" => "Provides details on monitoring configuration",
      }

      route /^zabbix monitor (pause|unpause).*$/i, :invalid_zabbixmon_syntax, command: true

      # DO (monitor) WORK
      on :connected, :run_monitors

      def invalid_zabbixmon_syntax(response)
        response.reply_with_mention('Invalid syntax; try "zabbix monitor <datacenter> pause/unpause"')
      end

      def initialize(robot)
        super
        @pager = \
          case config.pager.to_s
            when "pagerduty"
              ::Zabbix::PagerdutyPager.new(config.pagerduty_service_key)
            when "test"
              ::Zabbix::TestPager.new
            else
              raise ArgumentError, "unknown pager type: #{config.pager.to_s}"
          end
        @clients = Hash.new { |h, k| h[k] = build_zabbix_client(datacenter: k) }
        config.datacenters.each do |datacenter|
          begin
            maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
              datacenter: datacenter,
              redis: redis,
              client: @clients[datacenter],
              log: log)
            maintenance_supervisor.on_host_maintenance_expired = proc { |host| host_maintenance_expired(host) }
            maintenance_supervisor.ensure_supervising
          rescue => e
            log.error("Error creating Zabbix maintenance supervisor for #{datacenter}: #{e}")
          end
          begin
            monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
              datacenter: datacenter,
              redis: redis,
              client: @clients[datacenter],
              log: log)
            monitor_supervisor.on_monitor_unpaused = proc { |monitor| monitor_expired(monitor) }
            monitor_supervisor.ensure_supervising
          rescue => e
            log.error("Error creating Zabbix monitor supervisor for #{datacenter}: #{e}")
          end
        end
        @status_room = ::Lita::Source.new(room: config.status_room)
      end

      on(:connected) do
        robot.join(config.status_room)
      end

      def monitor_status(response)
        config.active_monitors.each do |active_monitor|
        msg ="\nMonitor / Status / Paging?"
          config.datacenters.each do |datacenter|
            if active_monitor == ::Zabbix::Zabbixmon::MONITOR_NAME
              monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
                datacenter: datacenter,
                redis: redis,
                client: @clients[datacenter],
                log: log)
              status = monitor_supervisor.get_paused_monitors.include?(::Zabbix::Zabbixmon::MONITOR_NAME) ? "paused (failed)" : "active (successful)"
              paging = config.paging_monitors.include? (::Zabbix::Zabbixmon::MONITOR_NAME) ? "PAGER: #{config.pager.to_s}" : "NOT PAGING"
              msg += "\n#{::Zabbix::Zabbixmon::MONITOR_NAME}-#{datacenter}  / #{status} / #{paging}"
              #TODO: Last known status per-datacenter
            end
          end
        end
        response.reply_with_mention("#{msg}")
      rescue => e
        errmsg="Error polling for Zabbix monitor status: #{e}"
        log.error(errmsg)
        response.reply_with_mention(errmsg)
      end

      def monitor_info(response)
        msg ="Datacenters: #{config.datacenters.join(',')}"
        msg +="\nActive Monitors: #{config.active_monitors.join(',')}"
        msg +="\nPaging Monitors: #{config.paging_monitors.join(',')}"
        msg +="\nMonitor Hipchat-Notify: #{config.monitor_hipchat_notify}"
        msg +="\nMonitor Interval (seconds): #{config.monitor_interval_seconds}"
        msg +="\nRetries: #{config.monitor_retries}"
        msg +="\nRetry Interval: #{config.monitor_retry_interval_seconds}"
        msg +="\nRead Timeout: #{config.monitor_http_timeout_seconds}"
        response.reply_with_mention("Monitor Status:\n#{msg}")
      end

      def start_maintenance(response)
        datacenter = response.match_data["datacenter"] || config.default_datacenter
        validate_datacenter(datacenter: datacenter, response: response) || return

        host_glob = response.match_data["host"]
        hosts = @clients[datacenter].search_hosts(host_glob)
        options = parse_options(response.match_data["options"])

        until_time = \
          if options["until"]
            begin
              HumanTime.parse(options["until"])
            rescue ArgumentError
              response.reply_with_mention("Sorry, I couldn't parse this duration: #{options["until"]}")
            end
          else
            Time.now + 3600
          end

        maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log,
        )

        hosts.each do |host|
          maintenance_supervisor.start_maintenance(
            host: host,
            until_time: until_time,
          )
        end

        if hosts.length > 0
          response.reply_with_mention("OK, I've started maintenance on #{host_glob} (matched #{hosts.length} hosts) until #{until_time}")
        else
          response.reply_with_mention("Sorry, no hosts matched #{host_glob}")
        end
      rescue => e
        response.reply_with_mention("Sorry, something went wrong: #{e}")
      end

      def pause_monitor(response)
        datacenter = response.match_data["datacenter"]
        response.reply("/me failed to parse a datacenter from your request. Defaulting to #{config.default_datacenter}") unless datacenter
        datacenter ||= config.default_datacenter
        validate_datacenter(datacenter: datacenter, response: response) || return
        options = parse_options(response.match_data["options"])
        until_time = \
          if options["until"]
           begin
             HumanTime.parse(options["until"])
           rescue ArgumentError
             response.reply_with_mention("Sorry, I couldn't parse this duration: #{options["until"]}")
           end
          else
            Time.now + 3600
          end
        monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log)
        monitor_supervisor.pause_monitor(
          monitorname: ::Zabbix::Zabbixmon::MONITOR_NAME,
          until_time: until_time)
        response.reply_with_mention("OK, I've paused zabbixmon for the #{datacenter} datacenter until #{until_time}")
      rescue ::Lita::Handlers::Zabbix::MonitorPauseFailed
        response.reply_with_mention("Sorry, something went wrong: ::Lita::Handlers::Zabbix::MonitorPauseFailed")
      end

      def stop_maintenance(response)
        datacenter = response.match_data["datacenter"] || config.default_datacenter
        validate_datacenter(datacenter: datacenter, response: response) || return

        host_glob = response.match_data["host"]
        hosts = @clients[datacenter].search_hosts(host_glob)

        maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log)
        hosts.each do |host|
          maintenance_supervisor.stop_maintenance(
            host: host)
        end

        if hosts.length > 0
          response.reply_with_mention("OK, I've stopped maintenance on #{host_glob} (matched #{hosts.length} hosts)")
        else
          response.reply_with_mention("Sorry, no hosts matched #{host_glob}")
        end
      rescue => e
        response.reply_with_mention("Sorry, something went wrong: #{e}")
      end

      def unpause_monitor(response)
        datacenter = response.match_data["datacenter"] || config.default_datacenter
        validate_datacenter(datacenter: datacenter, response: response) || return
        ::Zabbix::MonitorSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log,
        ).unpause_monitor(monitorname: ::Zabbix::Zabbixmon::MONITOR_NAME)
        response.reply_with_mention("OK, I've unpaused zabbixmon for datacenter #{datacenter}. Monitoring will resume.")
      rescue ::Lita::Handlers::Zabbix::MonitorUnpauseFailed
        response.reply_with_mention("Sorry, something went wrong: ::Lita::Handlers::Zabbix::MonitorUnpauseFailed")
      end


      def host_maintenance_expired(hostname)
        robot.send_message(@status_room, "/me is bringing #{hostname} out of maintenance")
      end

      def monitor_expired(monitorname)
        robot.send_message(@status_room, "/me is unpausing #{monitorname}")
      end

      def run_monitors(payload)
        every(config.monitor_interval_seconds) do |timer|
          begin # outer catch block: to keep things moving (handled)
          log.info("[#{::Zabbix::Zabbixmon::MONITOR_NAME}] executing run_monitors")
          config.datacenters.each do |datacenter|
            zabbixmon = ::Zabbix::Zabbixmon.new(redis: redis,
                zbx_client: @clients[datacenter],
                log: log,
                zbx_host: config.zabbix_hostname.gsub(/%datacenter%/, datacenter),
                zbx_username: config.zabbix_user,
                zbx_password: config.zabbix_password,
                datacenter: datacenter)
            begin # inner catch block: to be able to "see" what happened on failure (unhandled)
              monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
                datacenter: datacenter,
                redis: redis,
                log: log,
                client: @clients[datacenter])
              config.active_monitors.reject {|x| monitor_supervisor.get_paused_monitors.include? x}.each do |monitor|
                if monitor == ::Zabbix::Zabbixmon::MONITOR_NAME
                  log.debug("starting [#{::Zabbix::Zabbixmon::MONITOR_NAME}] Datacenter: #{datacenter}")
                  zabbixmon.monitor(config.monitor_retries,
                    config.monitor_retry_interval_seconds,
                    config.monitor_http_timeout_seconds)
                  log.info("[#{::Zabbix::Zabbixmon::MONITOR_NAME}] monitoring for #{::Zabbix::Zabbixmon::MONITOR_NAME}-#{datacenter} was successful.") if zabbixmon.hard_failure.nil?
                  monitor_fail_notify(zabbixmon.monitor_name,
                    datacenter,
                    zabbixmon.hard_failure,
                    config.monitor_hipchat_notify,
                    config.paging_monitors.include?(zabbixmon.monitor_name)
                  ) unless zabbixmon.hard_failure.nil?
                end
              end
            rescue => e
              log.error("::Lita::Handlers::Zabbix::run_monitors has failed (internal loop) (#{e})")
            end
          end
          rescue ::Lita::Handlers::Zabbix::MonitoringFailure
            log.error("::Lita::Handlers::Zabbix::run_monitors has failed")
            debug_output("::Lita::Handlers::Zabbix::run_monitors has failed")
            monitor_fail_notify(::Zabbix::Zabbixmon::MONITOR_NAME,
              'N/A',
              MONITOR_FAIL_ERRMSG,
              config.monitor_hipchat_notify,
              config.paging_monitors.include?(zabbixmon.monitor_name))
          end
        end
      end

      private
      def validate_datacenter(datacenter:, response:)
        if @clients.key?(datacenter)
          true
        else
          response.reply_with_mention("Sorry, there is no datacenter named #{datacenter}. Try #{@clients.keys.join(", ")}")
          false
        end
      end

      def build_zabbix_client(datacenter:)
        ::Zabbix::Client.new(url: config.zabbix_url.gsub(/%datacenter%/, datacenter),
          user: config.zabbix_user,
          password: config.zabbix_password)
      end

      def parse_options(options)
        Hash[Shellwords.split(options.to_s).map { |o| o.split("=", 2) }]
      end

      def monitor_fail_notify(monitorname, data_center, error_msg, notify_hipchat_channel, pagerduty_alert)
        if pagerduty_alert
          log.info("Paging sequence initiated. Paging pagerduty.")
          page_r_doodie(error_msg, data_center)
        end
        whining="#{monitorname} has encountered an error verifying the status of Zabbix-#{data_center}: #{error_msg}"
        log.info("Telling hipchat channel #{@status_room}: #{whining}")
        robot.send_message(@status_room, whining, notify_hipchat=notify_hipchat_channel)
      end

      def page_r_doodie(message:, datacenter:)
        @pager.trigger("#{message}", incident_key: ::Zabbix::Zabbixmon::INCIDENT_KEY % datacenter) unless (message.nil? || datacenter.nil?)
        robot.send_message(
          @status_room,
          "Error sending page: ::Lita::Handlers::Zabbix::PagerFailed (message: #{message}, datacenter=#{datacenter})",
          notify_hipchat=config.monitor_hipchat_notify
        ) if (message.nil? || datacenter.nil?)
        debug_output("A smoke signal appears over the horizon") if config.pager.to_s == 'test'
      rescue ::Lita::Handlers::Zabbix::PagerFailed
        log.error("Error sending page: ::Lita::Handlers::Zabbix::PagerFailed")
        robot.send_message(@status_room, "Error sending page: ::Lita::Handlers::Zabbix::PagerFailed", notify_hipchat=config.monitor_hipchat_notify)
      end

      def debug_output(message:)
        config.monitor_debug_out_targets.each do |target|
          robot.send_message(target, message)
        end
      end
      Lita.register_handler(self)
    end
  end
end
