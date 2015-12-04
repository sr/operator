require 'deploy_strategy_base'

class DeployStrategySymlink < DeployStrategyBase
  def deploy(artifact_path, deploy)
    ShellHelper.execute_shell("
      mkdir -p #{environment.payload.repo_path}
      ln -sfn #{artifact_path} #{environment.payload.remote_current_link}")
    $?.nil? || $?.exitstatus == 0 ? DEPLOY_SUCCESS : DEPLOY_FAILED
  end
end
