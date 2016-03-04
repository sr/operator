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

      route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+set\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :set_maintenance, command: true, help: {
        "zabbix maintenance set HOST" => "Puts HOST in maintenance mode for 1 hour",
        "zabbix maintenance set HOST until=24h" => "Puts HOST in maintenance mode for 24 hours",
      }


      def initialize(robot)
        super

        @clients = Hash.new { |h, k| h[k] = build_zabbix_client(datacenter: k) }
        config.datacenters.each do |datacenter|
          begin
            ::Zabbix::MaintenanceSupervisor.get_or_create(
              datacenter: datacenter,
              redis: redis,
              client: @clients[datacenter],
              log: log
            ).ensure_supervising
          rescue => e
            log.error("Error creating Zabbix maintenance supervisor for #{datacenter}: #{e}")
          end
        end

        @status_room = ::Lita::Source.new(room: config.status_room)
      end

      on(:connected) do
        robot.join(config.status_room)
      end

      def set_maintenance(response)
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

          maintenance_supervisor.set_maintenance(
            host: host,
            until_time: until_time,
          )

          response.reply_with_mention("OK, I've added #{host} to maintenance until #{until_time}")
        rescue => e
          response.reply_with_mention("Sorry, something went wrong: #{e}")
        end
      end

      def expire_maintenances
        @maintenance_supervisors.each do |_, supervisor|
          expired = supervisor.expire_maintenances
          expired.each do |host|
            robot.send_message(@status_room, "/me is removing #{host} from maintenance")
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
