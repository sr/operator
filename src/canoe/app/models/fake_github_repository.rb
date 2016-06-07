class FakeGithubRepository
  attr_writer :current_build, :current_deploy

  def current_build(branch)
    @current_build
  end

  def current_deploy(environment, sha)
    @current_deploy
  end

  def create_pending_deploy(environment, task, build)
    GithubRepository::Response.new(
      true,
      GithubRepository::Deploy.new(environment, build.sha, "pending")
    )
  end
end
