class DeployStrategyBase
  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def deploy(path, deploy)
    raise "Must be defined by sub-classes"
  end

  def rollback?(deploy)
    false
  end
end
