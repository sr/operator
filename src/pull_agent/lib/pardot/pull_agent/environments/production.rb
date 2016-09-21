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

        restart_task :add_graphite_annotation, only: :pardot
        restart_task :restart_redis_jobs, only: :pardot
        restart_task :restart_old_style_jobs, only: :pardot
        restart_task :restart_autojobs, only: :pardot

        after_deploy :restart_pithumbs_service, only: :pithumbs

        after_deploy :restart_salesedge, only: :'realtime-frontend'

        after_deploy :link_blue_mesh_env_file, only: :'blue-mesh'

        after_deploy :restart_workflowstats_service, only: :'workflow-stats'

        after_deploy :deploy_topology, only: :murdoc

        after_deploy :link_explorer_shared_files, only: :explorer
        after_deploy :restart_explorer, only: :explorer

        after_deploy :link_repfix_shared_files, only: :repfix
        after_deploy :restart_repfix_service, only: :repfix

        after_deploy :link_internal_api_shared_files, only: :'internal-api'
        after_deploy :restart_internal_api_service, only: :'internal-api'

        after_deploy :link_mesh_shared_files, only: :mesh
        after_deploy :restart_mesh_service, only: :mesh

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
