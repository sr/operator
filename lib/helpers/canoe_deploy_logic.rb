module Canoe
  module DeployLogic
    # ----------------------------------------------------------------------
    def deploy!
      # require a repo and target
      return nil if !current_repo || !current_target
      # confirm user can deploy
      return nil unless current_target.user_can_deploy?(current_user)

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

      current_target.deploy!(deploy_options) # return's deploy
    end

  end
end
