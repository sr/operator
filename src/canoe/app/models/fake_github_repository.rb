class FakeGithubRepository
  attr_writer :current_build, :current_deploy

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
        state: GithubRepository::PENDING
      )
    )
  end
end
