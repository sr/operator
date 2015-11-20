require "environment_production"
require "salesedge"

class EnvironmentProductionDfw < EnvironmentProduction
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
