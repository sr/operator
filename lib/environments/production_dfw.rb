require "helpers/salesedge"
require_relative "production"

module Environments
  class ProductionDfw < Production
    include SalesEdgeEnvModule

    after_deploy :restart_pithumbs_service, only: :pithumbs
    after_deploy :restart_salesedge, only: :'realtime-frontend'

    def short_name
      "prod_dfw"
    end

    def symfony_env
      "prod-s"
    end
  end

  register(:production_dfw, ProductionDfw)
end
