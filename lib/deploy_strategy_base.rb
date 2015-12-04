class DeployStrategyBase
  DEPLOY_SUCCESS = 0
  DEPLOY_FAILED  = 10

  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def deploy(artifact_path, deploy)
    raise "Must be defined by sub-classes"
  end

  def rollback?(deploy)
    false
  end
end
