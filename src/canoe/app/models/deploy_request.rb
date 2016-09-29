class DeployRequest
  ERROR_NO_PROJECT = 1
  ERROR_NO_TARGET = 2
  ERROR_NO_DEPLOY = 3
  ERROR_UNABLE_TO_DEPLOY = 4
  ERROR_INVALID_SHA = 5
  ERROR_DUPLICATE = 6

  class Response
    def self.error(code)
      new(true, code, nil)
    end

    def self.success(deploy)
      new(false, 0, deploy)
    end

    def initialize(error, code, deploy)
      @error = error
      @code = code
      @deploy = deploy
    end

    attr_reader :code, :deploy

    def error?
      @error
    end

    def error_message
      missing_error_codes = [
        ERROR_NO_PROJECT,
        ERROR_NO_TARGET,
        ERROR_NO_DEPLOY
      ]

      if missing_error_codes.include?(code)
        return "We did not have everything needed to deploy. Try again."
      end

      if code == ERROR_INVALID_SHA
        return "Sorry, it appears you specified an unknown artifact."
      end

      if code == ERROR_UNABLE_TO_DEPLOY
        return "Sorry, it looks like #{current_target.name} is locked."
      end
    end
  end

  def initialize(project, target, user, params)
    @project = project
    @target = target
    @user = user
    @params = params
  end

  def handle(prov_deploy)
    # require a project and target
    return Response.error(ERROR_NO_PROJECT) if !@project
    return Response.error(ERROR_NO_TARGET) if !@target
    # confirm user can deploy
    if !@target.user_can_deploy?(@project, @user)
      return Response.error(ERROR_UNABLE_TO_DEPLOY)
    end
    # confirm again there is no active deploy
    if !@target.active_deploy(@project).nil?
      return Response.error(ERROR_DUPLICATE)
    end

    # validate that provisional deploy was included and is a real thing
    if prov_deploy.nil?
      return Response.error(ERROR_NO_DEPLOY)
    end

    if !prov_deploy.valid?
      return Response.error(ERROR_INVALID_SHA)
    end

    the_deploy = deployer.deploy(
      target: @target,
      user: @user,
      project: @project,
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
      return Response.success(the_deploy)
    end

    Response.error(ERROR_DUPLICATE)
  end

  private

  def deployer
    @deployer ||= Canoe::Deployer.new
  end
end
