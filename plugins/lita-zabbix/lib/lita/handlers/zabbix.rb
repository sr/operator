require "zabbixapi"
require "zabbix/maintenance_supervisor"
require "zabbix/client"
require "human_time"

module Lita
  module Handlers
    class Zabbix < Handler
      config :zabbix_url, default: "https://zabbix-%datacenter%.pardot.com/api_jsonrpc.php"
      config :zabbix_user, default: "Admin"
      config :zabbix_password, required: "changeme"
      config :datacenters, default: ["dfw"]
      config :default_datacenter, default: "dfw"

      config :status_room, default: "1_ops@conf.btf.hipchat.com"

      config :host_domain, default: "ops.sfdc.net"

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
        "zabbix maintenance start HOST" => "Puts HOST in maintenance mode for 1 hour",
        "zabbix maintenance start HOST until=24h" => "Puts HOST in maintenance mode for 24 hours",
      }

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
        "zabbix maintenance stop HOST" => "Brings HOST out of maintenance mode",
      }

      def initialize(robot)
        super

        @clients = Hash.new { |h, k| h[k] = build_zabbix_client(datacenter: k) }
        config.datacenters.each do |datacenter|
          begin
            supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
              datacenter: datacenter,
              redis: redis,
              client: @clients[datacenter],
              log: log
            )

            supervisor.on_host_maintenance_expired = proc { |host| host_maintenance_expired(host) }
            supervisor.ensure_supervising
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

        host = host_with_fqdn(response.match_data["host"])
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

        begin
          maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
            datacenter: datacenter,
            redis: redis,
            client: @clients[datacenter],
            log: log,
          )

          maintenance_supervisor.start_maintenance(
            host: host,
            until_time: until_time,
          )

          response.reply_with_mention("OK, I've started #{host} maintenance on until #{until_time}")
        rescue => e
          response.reply_with_mention("Sorry, something went wrong: #{e}")
        end
      end

      def stop_maintenance(response)
        datacenter = response.match_data["datacenter"] || config.default_datacenter
        validate_datacenter(datacenter: datacenter, response: response) || return

        host = host_with_fqdn(response.match_data["host"])

        begin
          maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
            datacenter: datacenter,
            redis: redis,
            client: @clients[datacenter],
            log: log,
          )

          maintenance_supervisor.stop_maintenance(host: host)
          response.reply_with_mention("OK, I've brought #{host} out of maintenance")
        rescue => e
          response.reply_with_mention("Sorry, something went wrong: #{e}")
        end
      end

      def host_maintenance_expired(host)
        robot.send_message(@status_room, "/me is bringing #{host} out of maintenance")
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

      def host_with_fqdn(host)
        if host.end_with?(config.host_domain)
          host
        else
          [host, config.host_domain].join(".")
        end
      end

      def parse_options(options)
        Hash[Shellwords.split(options.to_s).map { |o| o.split("=", 2) }]
      end

      Lita.register_handler(self)
    end
  end
end
