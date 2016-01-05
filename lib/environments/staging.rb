require_relative "base"

module Environments
  class Staging < Base
    restart_task :restart_autojobs,
      :restart_old_style_jobs,
      :restart_redis_jobs,
      only: :pardot

    after_deploy :restart_murdoc, only: :murdoc
  end

  register(:staging, Staging)
end
