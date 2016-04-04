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
      config :active_monitors, default: 'zabbixmon'
      config :paging_monitors, default: ''

      config :status_room, default: "1_ops@conf.btf.hipchat.com"

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
        "zabbix maintenance start HOST" => "Puts hosts matching HOST in maintenance mode for 1 hour",
        "zabbix maintenance start HOST until=24h" => "Puts hosts matching HOST in maintenance mode for 24 hours",
      }

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
        "zabbix maintenance stop HOST" => "Brings hosts matching HOST out of maintenance mode",
      }

      def initialize(robot)
        super

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

            # insert your zabbix-based-monitor here

            # zabbixmon: engage!
            if monitor == zabbixmon.monitor_name
              zabbixmon.monitor(config.zabbix_host.gsub(/%datacenter%/, datacenter), config.zabbix_user, config.zabbix_password)

              zabbixmon.failures.each do |failure|
                monitor_hard_fail(zabbixmon.monitor_name, failure['datacenter'], failure['message'])
              end
            end
          end

        end
      end

      def monitor_fail_notify(response:, monitorname:, data_center:, error_msg:, status_room='', pagerduty_alert='')
        #let me sing you the song of my people

        if !pagerduty_alert.empty?
          #yo dawg, page pagerduty


        end

        if !status_room.empty?
          #fazha can you hear me?

        end

      end

      Lita.register_handler(self)
    end
  end
end
