class ChefCompleteDeployRequest
  def self.from_hash(request)
    new(
      request.fetch(:hostname),
      ChefDeploy.new(request.fetch(:deploy))
      request.fetch(:message, false)
    )
  end

  def initialize(hostname, deploy, error)
    @hostname = hostname
    @deploy = deploy
    @error = error
  end

  attr_reader :deploy, :error

  def deploy_id
    @deploy.id
  end

  def success?
    !@error
  end
end
