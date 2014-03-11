module Canoe
  module DeployLogic
    DEPLOYLOGIC_ERROR_NO_REPO   = 1
    DEPLOYLOGIC_ERROR_NO_TARGET = 2
    DEPLOYLOGIC_ERROR_NO_WHAT   = 3
    DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY = 4
    DEPLOYLOGIC_ERROR_INVALID_WHAT = 5

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

      # validate that what we are deploying was included and is a real thing
      return { error: true, reason: DEPLOYLOGIC_ERROR_NO_WHAT } if deploy_options[:what].nil?
      if !valid_what?(deploy_options[:what], deploy_options[:what_details])
        return { error: true, reason: DEPLOYLOGIC_ERROR_INVALID_WHAT, what: deploy_options[:what] }
      end

      the_deploy = current_target.deploy!(deploy_options)
      { error: false, deploy: the_deploy }
    end

    # silly generic naming... heh
    def valid_what?(what, what_details)
      case what
      when "tag"
        tags = tags_for_current_repo
        tags.collect(&:name).include?(what_details)
      when "branch"
        branches = branches_for_current_repo
        branches.include?(what_details)
      when "commit"
        commits = commits_for_current_repo
        found_commits = commits.select do |commit|
          commit.sha.match(%r{^#{what_details}})
        end
        !found_commits.empty?
      else
        false
      end
    end

  end
end
