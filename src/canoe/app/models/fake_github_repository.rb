class FakeGithubRepository
  attr_writer :current_build, :current_deploy, :complete_deploy

  def current_build(branch)
    @current_build
  end

  def current_deploy(environment, branch, deploy_task)
    @current_deploy
  end

  def create_pending_deploy(environment, task, build, branch)
    GithubRepository::Response.new(
      true,
      GithubRepository::Deploy.new(
        url: "http://github.com/#{build.sha}",
        environment: environment,
        branch: branch,
        sha: build.sha,
        state: ChefDelivery::PENDING
      )
    )
  end

  def complete_deploy(deploy_url, status)
    if @complete_deploy
      return @complete_deploy
    end

    GithubRepository::CompleteResponse.new(true, nil)
  end
end
