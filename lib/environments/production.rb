require "time"
require "helpers/salesedge"
require_relative "base"

module Environments
  class Production < Base
    include SalesEdgeEnvModule
    GRAPHITE_HOST = "10.107.195.209"
    GRAPHITE_PORT = "2003"

    restart_task :add_graphite_annotation, only: :pardot
    restart_task :restart_redis_jobs, only: :pardot
    restart_task :restart_old_style_jobs, only: :pardot
    restart_task :restart_autojobs, only: :pardot

    after_deploy :restart_pithumbs_service, only: :pithumbs

    after_deploy :restart_salesedge, only: :'realtime-frontend'

    after_deploy :link_blue_mesh_env_file, only: :'blue-mesh'

    after_deploy :restart_workflowstats_service, only: :'workflow-stats'

    after_deploy :deploy_topology, only: :'murdoc'

    def short_name
      "prod"
    end

    def add_graphite_annotation(deploy)
      cmd = "echo \"events.deploy.prod 1 #{Time.parse(deploy.created_at).to_i}\" | " + \
            "nc #{GRAPHITE_HOST} #{GRAPHITE_PORT}"
      ShellHelper.execute_shell(cmd)
    end
  end

  register(:production, Production)
end
