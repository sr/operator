require "zabbixapi"
require "zabbix/maintenance_supervisor"
require "zabbix/client"
require "zabbix/zabbixmon"
require "zabbix/monitor_supervisor"
require "zabbix/pagerduty_pager"
require "human_time"

module Lita
  module Handlers
    class Zabbix < Handler

      MonitorNotFound = Class.new(StandardError)
      MonitorPauseFailed = Class.new(StandardError)
      MonitorUnpauseFailed = Class.new(StandardError)
      MonitorDataInsertionFailed = Class.new(StandardError)
      PagerFailed = Class.new(StandardError)

      # config: zabbix
      config :zabbix_url, default: "https://zabbix-%datacenter%.pardot.com/api_jsonrpc.php"
      config :zabbix_hostname, default: 'zabbix-%datacenter%.pardot.com'
      config :zabbix_user, default: "Admin"
      config :zabbix_password, required: "changeme"

      # config: datacenters
      config :datacenters, default: ['dfw'], type: Array
      config :default_datacenter, default: 'dfw'

      # config: hal9000's "home room"
      config :status_room, default: '1_ops@conf.btf.hipchat.com'

      # config: zabbix monitor
      config :monitor_hipchat_notify, default: false
      config :monitor_interval_seconds, default: 60
      config :monitor_retries, default: 5
      config :monitor_retry_interval_seconds, default: 5
      config :monitor_http_timeout_seconds, default: 30
      config :active_monitors, default: [::Zabbix::Zabbixmon::MONITOR_NAME], type: Array
      config :paging_monitors, default: [], type: Array
      config :pager, default: 'test'

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
        "zabbix maintenance start HOST" => "Puts hosts matching HOST in maintenance mode for 1 hour",
        "zabbix maintenance start HOST until=24h" => "Puts hosts matching HOST in maintenance mode for 24 hours",
      }

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
        "zabbix maintenance stop HOST" => "Brings hosts matching HOST out of maintenance mode",
      }

      route /^zabbix monitor (?:-(?<datacenter>\S+))s+(?:pause)(?:\s+(?<options>.*))?$/i, :pause_monitor, command: true, help: {
        "zabbix monitor <datacenter> pause" => "Pauses the zabbix monitor for <datacenter> for 1 hour (options: #{@datacenter_options})",
        "zabbix monitor <datacenter> pause until=24h" => "Pauses the zabbix monitor for <datacenter> for 24 hours (options: #{@datacenter_options})",
      }

      route /^zabbix monitor (?:-(?<datacenter>\S+))\s+(?:unpause)(?:\s+(?<options>.*))?$/i, :unpause_monitor, command: true, help: {
        "zabbix monitor <datacenter> unpause" => "Unpauses <datacenter>s zabbix monitor [options: #{@datacenter_options}]",
      }

      route /^zabbix monitor status$/, :monitor_status, command:true,  help: {
        "zabbix monitor status" => "Provides details on monitoring particulars"
      }

      def initialize(robot)
        @datacenter_options = config.datacenters.join(",") #cant seem to use config.datacenters in route definition, so trying instance variable instead
        super
        @pager = \
          case config.pager.to_s
            when "pagerduty"
              ::Notifiers::PagerdutyPager.new(config.pagerduty_service_key)
            when "test"
              ::Notifiers::TestPager.new
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
              log: log
            )
            maintenance_supervisor.on_host_maintenance_expired = proc { |host| host_maintenance_expired(host) }
            maintenance_supervisor.ensure_supervising
            monitor_supervisor = ::Monitors::MonitorSupervisor.get_or_create(
                datacenter: datacenter,
                redis: redis,
                client: @clients[datacenter],
                log: log
            )

            monitor_supervisor.monitor_unpause = proc { |monitor| monitor_expired(monitor) }
            monitor_supervisor.ensure_supervising
          rescue => e
            log.error("Error creating Zabbix maintenance supervisor for #{datacenter}: #{e}")
          end
        end
        @status_room = ::Lita::Source.new(room: config.status_room)
      end

      on(:connected) do
        robot.join(config.status_room)
      end

      def monitor_status(response)
        msg +="Datacenters: #{config.datacenters.join(',')}"
        msg = "\nActive Monitors: #{config.active_monitors.join[',']}"
        msg +="\nPaging Monitors: #{config.paging_monitors.join[',']}"
        msg +="\nMonitor Hipchat-Notify: #{config.monitor_hipchat_notify}"
        msg +="\nMonitor Interval (seconds): #{config.monitor_interval_seconds}"
        msg +="\nRetries: #{config.monitor_retries}"
        msg +="\nRetry Interval: #{config.monitor_retry_interval_seconds}"
        msg +="\nRead Timeout: #{config.monitor_http_read_timeout_seconds}"
        #TODO: Last known status per-datacenter

        msg += "\n#{k}: #{v}" if k.include?(::Zabbix::Zabbixmon::MONITOR_SHORTHAND)

        response.reply_with_mention("Monitor Status:\n#{msg}")
      rescue => e
        response.reply_with_mention("Sorry, the monitor status check failed: #{e}")
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

        monitor_supervisor = ::Zabbixmon::MonitorSupervisor.get_or_create(
            datacenter: datacenter,
            redis: redis,
            client: @clients[datacenter],
            log: log,
        )

        monitor_supervisor.pause_monitor(
            monitorname: ::Zabbixmon::MONITOR_NAME,
            until_time: until_time,
        )

        response.reply_with_mention("OK, I've paused zabbixmon for the #{datacenter} datacenter until #{until_time}")
      rescue ::Lita::Handlers::Zabbix::MonitorPauseFailed
        response.reply_with_mention("Sorry, something went wrong: #{e}")
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
          log: log,
        )

        hosts.each do |host|
          maintenance_supervisor.stop_maintenance(
            host: host,
          )
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
        monitor_supervisor = ::Zabbixmon::MonitorSupervisor.get_or_create(
            datacenter: datacenter,
            redis: redis,
            client: @clients[datacenter],
            log: log,
        )
        monitor_supervisor.unpause_monitor(::Zabbixmon::MONITOR_NAME)
        response.reply_with_mention("OK, I've unpaused zabbixmon for datacenter #{datacenter}. Monitoring will resume.")

      rescue ::Lita::Handlers::Zabbix::MonitorUnpauseFailed
        response.reply_with_mention("Sorry, something went wrong: #{e}")
      end


      def host_maintenance_expired(hostname)
        robot.send_message(@status_room, "/me is bringing #{hostname} out of maintenance")
      end

      def monitor_expired(monitorname)
        robot.send_message(@status_room, "/me is unpausing #{monitorname}")
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
        ::Zabbix::Client.new(
          url: config.zabbix_url.gsub(/%datacenter%/, datacenter),
          user: config.zabbix_user,
          password: config.zabbix_password,
        )
      end

      def parse_options(options)
        Hash[Shellwords.split(options.to_s).map { |o| o.split("=", 2) }]
      end

      def run_monitors(response)
        every(config.monitor_interval_seconds) do |timer|

          # instantiate zabbixmon monitor
          zabbixmon = ::Monitors::Zabbixmon.new(
              redis: redis,
              clients: @clients,
              log: log,
          )

          # for each datacenter
          config.datacenters.each do |datacenter|
            monitor_supervisor = ::Monitors::MonitorSupervisor.get_or_create(
                datacenter: datacenter,
                redis: redis,
                log: log,
            )

            # loop through (active && unpaused) monitors
            active_monitors.reject {|x| monitor_supervisor.get_paused_monitors.include? x}.each do |monitor|
              # zabbixmon: engage!
              if monitor == ::Zabbixmon::MONITOR_NAME
                zabbixmon.monitor(
                  config.zabbix_host.gsub(/%datacenter%/, datacenter),
                  config.zabbix_user,
                  config.zabbix_password,
                  datacenter,
                  config.zbxmon_payload_length,
                  config.monitor_retries,
                  config.monitor_retry_interval_seconds,
                  config.monitor_http_timeout_seconds,
                )
              end
            end

            # bitch and moan (unless ...)
            monitor_fail_notify(zabbixmon.monitor_name,
                                datacenter,
                                zabbixmon.hard_failure,
                                config.zbxmon_hipchat_notify,
                                config.paging_monitors.include?(zabbixmon.monitor_name)
            ) unless zabbixmon.hard_failure.nil?

          end
        end
      end

      def monitor_fail_notify(monitorname, data_center, error_msg, notify_hipchat_channel, pagerduty_alert)
        #let me sing you the song of my people

        if pagerduty_alert
          #yo dawg, page pagerduty
          @log.info("Paging sequence initiated. Paging pagerduty.")
          #TODO: PAGE-R-(seriouspoo)
        end

        #fazha can you hear me?
        whining="#{monitorname} has encountered an error verifying the status of Zabbix-#{data_center}: #{error_msg}"
        @log.info("Telling hipchat channel #{@status_room}: #{whining}")
        robot.send_message(@status_room, whining, notify_hipchat=notify_hipchat_channel)
      end

      def page_r_doodie(message:, datacenter:)
        @pager.trigger("#{message}", incident_key: ::Zabbixmon::INCIDENT_KEY.gsub('%datacenter%',datacenter))
      rescue ::Lita::Handlers::Zabbix::PagerFailed
        @log.error("Error sending page: #{e}")
      end

      Lita.register_handler(self)
    end
  end
end
