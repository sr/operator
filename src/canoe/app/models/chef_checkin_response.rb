class ChefCheckinResponse
  def self.noop
    return new("noop", nil)
  end

  def self.deploy(deploy)
    return new("deploy", deploy)
  end

  def initialize(action, deploy)
    @action = action
    @deploy = deploy
  end

  attr_reader :action, :deploy

  def to_json
    {
      "action" => @action,
      "deploy" => @deploy
    }
  end
end
