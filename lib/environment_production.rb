require "environment_base"
require "shell_helper"

class EnvironmentProduction < EnvironmentBase
  after_deploy  :bounce_redis_workers, only: :pardot

  def short_name
    "prod"
  end

  def skip_redis_bounce?
    ShellHelper.hostname != "autojob-s47"
  end
end
