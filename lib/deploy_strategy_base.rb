class DeployStrategyBase
  attr_accessor :environment, :label

  def initialize(environment)
    self.environment = environment
  end

  def deploy(path, label='')
    raise "Must be defined by sub-classes"
  end

  def rollback?(label)
    false
  end
end