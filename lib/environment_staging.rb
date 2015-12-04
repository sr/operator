require "environment_base"
require "storm"

class EnvironmentStaging < EnvironmentBase
  include StormEnvModule
  restart_task :restart_autojobs,
    :restart_old_style_jobs,
    :restart_redis_jobs,
    only: :pardot

  deploy_strategy :symlink, only: :murdoc
  after_deploy :load_murdoc, only: :murdoc
end
