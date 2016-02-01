require "helpers/salesedge"
require_relative "production"

module Environments
  class ProductionDfw < Production
    include SalesEdgeEnvModule

    restart_task :restart_redis_jobs, only: :pardot
    restart_task :restart_old_style_jobs, only: :pardot
    restart_task :restart_autojobs, only: :pardot

    after_deploy :restart_pithumbs_service, only: :pithumbs

    after_deploy :restart_salesedge, only: :'realtime-frontend'

    after_deploy :restart_workflowstats_service, only: :'workflow-stats'

    after_deploy :deploy_topology, only: :'murdoc'

    def short_name
      "prod_dfw"
    end

    def symfony_env
      "prod-s"
    end
  end

  register(:production_dfw, ProductionDfw)
end
