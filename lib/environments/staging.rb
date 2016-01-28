require_relative "base"

module Environments
  class Staging < Base
    restart_task :restart_autojobs,
      :restart_old_style_jobs,
      :restart_redis_jobs,
      only: :pardot
  end

  register(:staging, Staging)
end
