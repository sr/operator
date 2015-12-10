require "time"
require_relative "environment_base"
require_relative "helpers/salesedge"

class EnvironmentProduction < EnvironmentBase
  include SalesEdgeEnvModule
  GRAPHITE_HOST = "10.107.195.209"
  GRAPHITE_PORT = "2003"

  restart_task :add_graphite_annotation, only: :pardot
  after_deploy :restart_pithumbs_service, only: :pithumbs
  after_deploy :restart_salesedge, only: :'realtime-frontend'

  def short_name
    "prod"
  end

  def add_graphite_annotation(deploy)
    cmd = "echo \"events.deploy.prod 1 #{Time.parse(deploy.created_at).to_i}\" | " + \
          "nc #{GRAPHITE_HOST} #{GRAPHITE_PORT}"
    ShellHelper.execute_shell(cmd)
  end
end
