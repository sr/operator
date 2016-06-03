class GithubDeployment
  def initialize(client)
    @client = client
  end

  def create(deploy)
    options = {
      environment: @deploy.environment,
      required_contexts: @deploy.required_contexts,
    }
    @github.create_deployment(@deploy.repo, deploy.sha1, options)
  end

  def start(deploy_id)
  end

  def complete(deploy_id, successful)
  end
end
