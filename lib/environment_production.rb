require "environment_base"

class EnvironmentProduction < EnvironmentBase
  restart_task :restart_pardot_jobs, only: :pardot

  def short_name
    "prod"
  end
end
