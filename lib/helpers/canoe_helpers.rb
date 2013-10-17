module Canoe
  module Helpers
    # ----------------------------------------------------------------------
    # CURRENT X
    def current_user
      @_current_user ||= \
        session[:user_id] ? AuthUser.where(id: session[:user_id].to_i).first : nil
    end

    def current_repo
      return nil unless %w[pardot symfony].include?((params[:repo_name] || '').downcase)
      @_current_repo ||= Octokit.repo("pardot/#{params[:repo_name]}")
    end

    def current_target
      @_current_target ||= DeployTarget.where(name: params[:target_name]).first
    end

    def current_deploy
      @_current_deploy ||= Deploy.where(id: params[:deploy_id].to_i).first
    end

    # ----------------------------------------------------------------------
    # DATA
    def all_targets
      @_all_targets ||= DeployTarget.order(:name)
    end

    def get_recent_deploys_for_repos
      @last_repo_deploys = {}
      %w[pardot symfony].each do |repo|
        @last_repo_deploys[repo] = \
          current_target.deploys.where(repo_name: repo).order('created_at DESC').first
      end
    end

    # ----------------------------------------------------------------------
    # ACTIVE X
    def active_repo(repo_name)
      current_repo && current_repo.name.downcase == repo_name.downcase ? 'class="active"' : ""
    end

    def active_target(target_name)
      current_target && current_target.name.downcase == target_name.downcase ? 'class="active"' : ""
    end

    # ----------------------------------------------------------------------
    # PATHS
    def repo_path
      "/repo/#{current_repo.name}"
    end

    def deploy_path(options)
      path = "#{repo_path}/deploy?"
      options.each { |key,value| path += "#{key}=#{CGI.escape(value)}&" }
      path.gsub!(/\&$/,'') # remove any trailing &'s
      path
    end

    def deploy_target_path(target, deploy_type)
      path = "/deploy/target/#{target.name}?"
      path += "repo_name=#{current_repo.name}&"
      path += "#{deploy_type.name}=#{deploy_type.details}"
      path
    end

    def github_url
      "https://github.com"
    end

    def github_tag_url(tag)
      "#{github_url}/#{current_repo.full_name}/releases/tag/#{tag.name}"
    end

    def github_branch_url(branch)
      "#{github_url}/#{current_repo.full_name}/tree/#{branch.name}"
    end

    def github_commit_url(commit)
      "#{github_url}/#{current_repo.full_name}/commits/#{commit.sha}"
    end

    # ----------------------------------------------------------------------
    # HTML Helpers
    def deploy_type_icon(type)
      case type
      when 'tag'
        "<i class='icon-tag' title='tag'></i>"
      when 'branch'
        "<i class='icon-code-fork' title='branch'></i>"
      when 'commit'
        "<i class='icon-tasks' title='commit'></i>"
      else
        ''
      end
    end

    def sha_span(sha)
      "<span title='#{sha}' class='js-sha-expand' data-sha='#{sha}'>#{sha[0,12]}...</span>"
    end

    # ----------------------------------------------------------------------
    # PRINT
    def print_deploy_what(deploy)
      output = deploy_type_icon(deploy.what)
      output += " "
      if deploy.what == "commit"
        output += sha_span(deploy.what_details)
      else
        output += deploy.what_details
      end
      output
    end

    def print_time(time)
      time.localtime.strftime("%m/%d/%y @ %l:%M %p")
    end

  end
end