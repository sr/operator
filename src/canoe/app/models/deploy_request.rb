class DeployRequest
  ERROR_NO_PROJECT = 1
  ERROR_NO_TARGET = 2
  ERROR_NO_DEPLOY = 3
  ERROR_UNABLE_TO_DEPLOY = 4
  ERROR_INVALID_SHA = 5
  ERROR_DUPLICATE = 6

  def initialize(project, target, user, params)
    @project = project
    @target = target
    @user = user
    @params = params
  end

  def handle(prov_deploy)
    # require a project and target
    return { error: true, reason: ERROR_NO_PROJECT } if !current_project
    return { error: true, reason: ERROR_NO_TARGET } if !current_target
    # confirm user can deploy
    if !current_target.user_can_deploy?(current_project, current_user)
      return { error: true, reason: ERROR_UNABLE_TO_DEPLOY }
    end
    # confirm again there is no active deploy
    if !current_target.active_deploy(current_project).nil?
      return { error: true, reason: ERROR_DUPLICATE }
    end

    # validate that provisional deploy was included and is a real thing
    if prov_deploy.nil?
      return { error: true, reason: ERROR_NO_DEPLOY }
    elsif !prov_deploy.valid?
      return { error: true,
               reason: ERROR_INVALID_SHA,
               what: prov_deploy.sha }
    end

    the_deploy = deployer.deploy(
      target: current_target,
      user: current_user,
      project: current_project,
      branch: prov_deploy.branch,
      sha: prov_deploy.sha,
      build_number: prov_deploy.build_number,
      artifact_url: prov_deploy.artifact_url,
      passed_ci: prov_deploy.passed_ci,
      lock: (@params[:lock] == "on"),
      server_hostnames: (@params[:servers] == "on" && @params.fetch(:server_hostnames, [])),
      options_validator: prov_deploy.options_validator,
      options: @params[:options],
    )

    if the_deploy
      { error: false, deploy: the_deploy }
    else
      # likely cause of nil response is a duplicate deploy (another guard)
      { error: true, reason: ERROR_DUPLICATE }
    end
  end

  private

  def current_user
    @user
  end

  def current_project
    @project
  end

  def current_target
    @target
  end

  def deployer
    @deployer ||= Canoe::Deployer.new
  end
end
