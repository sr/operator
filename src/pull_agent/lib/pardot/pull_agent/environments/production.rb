module Pardot
  module PullAgent
    module Environments
      class Production < Base
        include SalesEdgeEnvModule

        GRAPHITE_HOST = {
          # pardot0-metrics1-2-dfw.ops.sfdc.net
          "dfw" => "10.247.178.234",
          # pardot0-metrics1-2-phx.ops.sfdc.net
          "phx" => "10.246.178.235"
        }.freeze

        GRAPHITE_PORT = "2003".freeze

        after_deploy :link_correct_inventory, only: :ansible

        after_deploy :deploy_topology, only: :'engagement-history-topology'

        def short_name
          "prod"
        end

        def symfony_env
          "prod-s"
        end

        def add_graphite_annotation(deploy)
          host = GRAPHITE_HOST.fetch(ShellHelper.datacenter)

          Timeout.timeout(5) do
            TCPSocket.open(host, GRAPHITE_PORT) do |sock|
              sock.puts("events.deploy.prod 1 #{Time.parse(deploy.created_at).to_i}")
              sock.close_write
            end
          end
        rescue
          Logger.log(:error, "Unable to connect to graphite: #{$!}")
        end
      end

      register(:production, Production)
    end
  end
end
