require "zabbixapi"
require "zabbix/maintenance_supervisor"
require "zabbix/client"
require "monitors/zabbixmon"
require "monitors/monitor_supervisor"
require "notifiers/pagerduty_pager"
require "human_time"

module Lita
  module Handlers
    class Zabbix < Handler

      MonitorNotFound = Class.new(StandardError)

      config :zabbix_url, default: "https://zabbix-%datacenter%.pardot.com/api_jsonrpc.php"
      config :zabbix_hostname, default: 'zabbix-%datacenter%.pardot.com'
      config :zabbix_user, default: "Admin"
      config :zabbix_password, required: "changeme"
      config :datacenters, default: ["dfw"]
      config :default_datacenter, default: "dfw"
      config :monitor_interval_seconds, default: 60
      config :active_monitors, default: [::Zabbixmon::MONITOR_NAME]
      config :paging_monitors, default: []
      config :pager, default: "test"

      config :status_room, default: "1_ops@conf.btf.hipchat.com"

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
        "zabbix maintenance start HOST" => "Puts hosts matching HOST in maintenance mode for 1 hour",
        "zabbix maintenance start HOST until=24h" => "Puts hosts matching HOST in maintenance mode for 24 hours",
      }

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
        "zabbix maintenance stop HOST" => "Brings hosts matching HOST out of maintenance mode",
      }

      route /^zabbixmon(?:-(?<datacenter>\S+))s+(?:pause)(?:\s+(?<options>.*))?$/i, :pause_monitor, command: true, help: {
          "zabbixmon <datacenter> pause" => "Pauses the zabbix monitor for <datacenter> for 1 hour [options: #{config.datacenters.join(",")}]",
          "zabbixmon <datacenter> pause until=24h" => "Pauses the zabbix monitor for <datacenter> for 24 hours [options: #{config.datacenters.join(",")}]",
      }

      route /^zabbixmon(?:-(?<datacenter>\S+))\s+(?:unpause)(?:\s+(?<options>.*))?$/i, :unpause_monitor, command: true, help: {
          "zabbixmon <datacenter> unpause" => "Unpauses <datacenter>s zabbix monitor [options: #{config.datacenters.join(",")}]",
      }



      def initialize(robot)
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
        datacenter = response.match_data["datacenter"] || config.default_datacenter
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
      rescue => e
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

      rescue => e
        response.reply_with_mention("Sorry, something went wrong: #{e}")
      end


      def host_maintenance_expired(hostname)
        robot.send_message(@status_room, "/me is bringing #{hostname} out of maintenance")
      end

      def monitor_expired(monitorname)
        robot.send_message(@status_room, "/me is unpausing #{monitor}")
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

          config.datacenters.each do |datacenter|

            monitor_supervisor = ::Monitors::MonitorSupervisor.get_or_create(
                datacenter: datacenter,
                redis: redis,
                log: log,
            )

            zabbixmon = ::Monitors::Zabbixmon.new(
                datacenters: config.datacenters,
                redis: redis,
                clients: @clients,
                log: log,
            )

            # loop through (active && unpaused) monitors
            active_monitors.reject {|x| monitor_supervisor.get_paused_monitors.include? x}.each do |monitor|

              # zabbixmon: engage!
              if monitor == ::Zabbixmon::MONITOR_NAME
                zabbixmon.monitor(config.zabbix_host.gsub(/%datacenter%/, datacenter), config.zabbix_user, datacenter)


                monitor_fail_notify(zabbixmon.monitor_name,
                                    datacenter,
                                    zabbixmon.hard_failure,
                                    zabbixmon.notify_status_channel?,
                                    config.paging_monitors.include?(zabbixmon.monitor_name)
                ) unless zabbixmon.hard_failure.nil?
              end

            end
          end
        end
      end

      def monitor_fail_notify(monitorname, data_center, error_msg, notify_hipchat_channel, pagerduty_alert)
        #let me sing you the song of my people

        if pagerduty_alert
          #yo dawg, page pagerduty
          @log.info("Paging sequence initiated. Paging pagerduty")
          #TODO: PAGE-R-(seriouspoo)
        end

        #fazha can you hear me?
        whining="#{monitorname} has encountered an error verifying the status of Zabbix-#{data_center}: #{error_msg}"
        @log.info("Telling hipchat channel #{@status_room}: #{whining}")
        robot.send_message(@status_room, whining, notify_hipchat=notify_hipchat_channel)
      end

      def page_r_doodie(message:, datacenter:)
        @pager.trigger("#{message}", incident_key: ::Zabbixmon::INCIDENT_KEY.gsub('%datacenter%',datacenter))
      rescue => e
        @log.error("Error sending page: #{e}")
      end

      Lita.register_handler(self)
    end
  end
end
