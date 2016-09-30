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

    def to_json(_)
      JSON.dump(error: @error, message: error_message, deploy: @deploy.attributes)
    end
  end

  def initialize(project, target, user, artifact_url, lock, servers, options)
    @project = project
    @target = target
    @user = user
    @artifact_url = artifact_url
    @lock = lock
    @servers = servers
    @options = options
  end

  def handle
    if !@project
      return Response.error(ERROR_NO_PROJECT)
    end

    if !@target
      return Response.error(ERROR_NO_TARGET)
    end

    if !@target.user_can_deploy?(@project, @user)
      return Response.error(ERROR_UNABLE_TO_DEPLOY)
    end

    if !@target.active_deploy(@project).nil?
      return Response.error(ERROR_DUPLICATE)
    end

    if !build
      return Response.error(ERROR_NO_DEPLOY)
    end

    if !build.valid?
      return Response.error(ERROR_INVALID_SHA)
    end

    the_deploy = deployer.deploy(
      target: @target,
      user: @user,
      project: @project,
      branch: build.branch,
      sha: build.sha,
      build_number: build.build_number,
      artifact_url: build.artifact_url,
      passed_ci: build.passed_ci,
      lock: @lock,
      server_hostnames: @servers,
      options_validator: build.options_validator,
      options: @options,
    )

    if the_deploy
      return Response.success(the_deploy)
    end

    Response.error(ERROR_DUPLICATE)
  end

  private

  def build
    @build ||= Build.from_artifact_url(@project, @artifact_url)
  end

  def deployer
    @deployer ||= Canoe::Deployer.new
  end
end
