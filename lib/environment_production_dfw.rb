require "environment_production"

class EnvironmentProductionDfw < EnvironmentProduction
  def short_name
    "prod_dfw"
  end

  def symfony_env
    "prod-s"
  end
end
