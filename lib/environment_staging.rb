require "environment_base"

class EnvironmentStaging < EnvironmentBase
  restart_task :restart_pardot_jobs, only: :pardot
end
