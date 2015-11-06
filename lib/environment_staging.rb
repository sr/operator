require "environment_base"

class EnvironmentStaging < EnvironmentBase
  restart_task :restart_autojobs,
    :restart_old_style_jobs,
    :restart_redis_jobs,
    only: :pardot
end
