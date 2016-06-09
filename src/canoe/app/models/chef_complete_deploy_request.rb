class ChefCompleteDeployRequest
  def self.from_hash(request)
    deploy = GithubRepository::Deploy.new(request.fetch(:deploy))

    new(deploy, request.fetch(:message, false))
  end

  def initialize(deploy, error)
    @deploy = deploy
    @error = error
  end

  attr_reader :deploy, :error

  def deploy_url
    @deploy.url
  end

  def success?
    !@error
  end
end
