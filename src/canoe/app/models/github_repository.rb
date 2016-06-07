class GithubRepository
  class Error < StandardError; end

  Build = Struct.new(:sha, :state)
  Deploy = Struct.new(:environment, :sha, :state)

  def initialize(client, name)
    @client = client
    @name = name
  end

  def current_build(branch)
    statuses = Octokit.combined_statuses(@name, branch)

    if statuses.empty?
      return GithubBuild.new(nil, "failure")
    end

    status = statuses.first
    Build.new(status[:sha], status[:state])
  end

  def current_deploy(environment, sha)
    options = {
      environment: request.environemnt,
      sha: current_build.sha,
      task: @config.deploy_task_name
    }
    deploys = Octokit.deployments(@repo_name, options)

    if deploys.empty?
      return GithubDeploy.new(request.environment, nil, nil)
    end

    deploy = deploys[0]
    statuses = Octokit.list_deployment_statuses(deploy[:url])

    if statuses.empty?
      return Deploy.new(deploy[:environment], "pending", deploy[:sha])
    end

    status = statuses[0]
    Deploy.new(deploy[:environment], status[:state], deploy[:sha])
  end

  Response = Struct.new(:success?, :deploy)

  def create_pending_deploy(environment, task, build)
    options = {
      auto_merge: false,
      environment: environment,
      required_contexts: Array(build.context),
      task: task
    }

    deploy = Octokit.create_deployment(@name, build.sha, options)

    if deploy[:url].blank?
      raise Error, "unable to create deploy"
    end

    # TODO(sr) Return a Deploy object here
    Response.new(
      true,
      Octokit.create_deployment_status(deploy[:url], "pending"),
    )
  end
end
