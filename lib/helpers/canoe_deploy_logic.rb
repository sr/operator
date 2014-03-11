module Canoe
  module DeployLogic
    DEPLOYLOGIC_ERROR_NO_REPO   = 1
    DEPLOYLOGIC_ERROR_NO_TARGET = 2
    DEPLOYLOGIC_ERROR_NO_WHAT   = 3
    DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY = 4

    # ----------------------------------------------------------------------
    def deploy!
      # require a repo and target
      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_REPO   } if !current_repo
      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_TARGET } if !current_target
      # confirm user can deploy
      if !current_target.user_can_deploy?(current_user)
        return { error: true, reason: DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY }
      end

      deploy_options = { user: current_user,
                         repo: current_repo,
                         lock: (params[:lock] == "on"),
                       }

      # let's determine what we're deploying...
      %w[tag branch commit].each do |type|
        if params[type]
          deploy_options[:what] = type
          deploy_options[:what_details] = params[type]
          break
        end
      end

      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_WHAT } if deploy_options[:what].nil?

      the_deploy = current_target.deploy!(deploy_options)
      { error: false, deploy: the_deploy }
    end

  end
end
