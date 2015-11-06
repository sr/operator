require "environment_base"
require "time"

class EnvironmentProduction < EnvironmentBase
  GRAPHITE_HOST = "10.107.195.209"
  GRAPHITE_PORT = "2003"

  restart_task :add_graphite_annotation, only: :pardot

  def short_name
    "prod"
  end

  def add_graphite_annotation(deploy)
    cmd = "echo \"events.deploy.prod 1 #{Time.parse(deploy.created_at).to_i}\" | " + \
          "nc #{GRAPHITE_HOST} #{GRAPHITE_PORT}"
    ShellHelper.execute_shell(cmd)
  end
end
