module Canoe
  # TODO: Break this out into something that doesn't have to be mixed into a
  # controller to work correctly. Specifically, we need to break the
  # dependencies on `current_repo`, `current_target`, and `params`. -@alindeman
  module DeployLogic
    DEPLOYLOGIC_ERROR_NO_REPO   = 1
    DEPLOYLOGIC_ERROR_NO_TARGET = 2
    DEPLOYLOGIC_ERROR_NO_WHAT   = 3
    DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY = 4
    DEPLOYLOGIC_ERROR_INVALID_WHAT = 5
    DEPLOYLOGIC_ERROR_DUPLICATE = 6

    # ----------------------------------------------------------------------
    def deploy!(prov_deploy)
      # require a repo and target
      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_REPO   } if !current_repo
      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_TARGET } if !current_target
      # confirm user can deploy
      if !current_target.user_can_deploy?(current_repo, current_user)
        return { error: true, reason: DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY }
      end
      # confirm again there is no active deploy
      if !current_target.active_deploy(current_repo).nil?
        return { error: true, reason: DEPLOYLOGIC_ERROR_DUPLICATE }
      end

      # validate that what we are deploying was included and is a real thing
      if prov_deploy.nil?
        return { error: true, reason: DEPLOYLOGIC_ERROR_NO_WHAT }
      elsif !prov_deploy.is_valid?
        return { error: true,
                 reason: DEPLOYLOGIC_ERROR_INVALID_WHAT,
                 what: prov_deploy.what }
      end

      the_deploy = deployer.deploy(
        target: current_target,
        user: current_user,
        repo: current_repo,
        what: prov_deploy.what,
        what_details: prov_deploy.what_details,
        sha: prov_deploy.sha,
        build_number: prov_deploy.build_number,
        artifact_url: prov_deploy.artifact_url,
        passed_ci: prov_deploy.passed_ci,
        lock: (params[:lock] == "on"),
        server_hostnames: (params[:servers] == "on" && params.fetch(:server_hostnames, [])),
        options_validator: prov_deploy.options_validator,
        options: params[:options],
      )

      if the_deploy
        { error: false, deploy: the_deploy }
      else
        # likely cause of nil response is a duplicate deploy (another guard)
        { error: true, reason: DEPLOYLOGIC_ERROR_DUPLICATE }
      end
    end

    def lock_target!
      deployer.lock(target: current_target, user: current_user)
    end

    def unlock_target!(force: false)
      deployer.unlock(target: current_target, user: current_user, force: force)
    end

    private
    def deployer
      @deployer ||= Canoe::Deployer.new
    end
  end
end
