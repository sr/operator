class ChefCheckinResponse
  def self.noop
    new("noop", nil)
  end

  def self.deploy(deploy)
    new("deploy", deploy)
  end

  def initialize(action, deploy)
    @action = action
    @deploy = deploy
  end

  attr_reader :action, :deploy

  def to_json(_)
    JSON.dump(
      action: @action,
      deploy: @deploy
    )
  end
end
