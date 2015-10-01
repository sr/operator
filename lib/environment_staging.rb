require "environment_base"
require "shell_helper"

class EnvironmentStaging < EnvironmentBase
  after_deploy  :bounce_redis_workers, only: :pardot

  def perform_redis_bounce?
    ShellHelper.hostname == "job-d1.dev"
  end
end
