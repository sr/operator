require 'deploy_strategy_base'
require 'shell_helper'

class DeployStrategySymlink < DeployStrategyBase
  # =======================================================
  # remote directory structure
  #
  # .../<remote path>
  #     |
  #     +- <current link> -> symlink into releases
  #     |
  #     +- <releases directory>
  #         \
  #          +- workflow-stats-SNAPSHOT-64-a4495f.jar
  #          +- workflow-stats-SNAPSHOT-65-rd907d.jar
  # =======================================================

  def deploy_to_server(local_path, server)
    releases_path = path_with_trailing_slash(File.expand_path("releases", environment.payload.remote_path))
    scp_cmd = "#{@environment.sudo} scp #{local_path} #{server}:#{releases_path}"
    output = ShellHelper.execute_shell(scp_cmd)
    Console.log(output)

    new_path = File.expand_path(File.basename(local_path), releases_path)

    symlink_cmd = "ln -sfn #{new_path} #{environment.payload.remote_current_link}"

    Console.log("LINK: #{server} - [MOVE] current -> '#{new_path}'", :yellow)
    output = ShellHelper.remote(server, symlink_cmd, @environment)
    Console.log(output) unless output.strip.empty?

    DEPLOY_SUCCESS
  end
end
