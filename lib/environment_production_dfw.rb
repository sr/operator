require "environment_production"

class EnvironmentProductionDfw < EnvironmentProduction
  after_deploy :restart_pithumbs_service, only: :pithumbs

  def short_name
    "prod_dfw"
  end

  def symfony_env
    "prod-s"
  end
end
