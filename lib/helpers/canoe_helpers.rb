module Canoe
  module Helpers
    def use_https?
      self.class.is_production?
    end

    def protocol_for_includes
      use_https? ? "https" : "http"
    end

    # ----------------------------------------------------------------------
    # CURRENT X
    def current_user
      @_current_user ||= \
        if is_api?
          params[:user_email] ? AuthUser.where(email: params[:user_email]).first : nil
        else
          session[:user_id] ? AuthUser.where(id: session[:user_id].to_i).first : nil
        end
    end

    def current_repo
      @_current_repo ||= \
        begin
          repo_name = ""
          if params[:repo_name].blank? && current_deploy.nil?
            return nil # if we don't have anything, bail
          elsif !params[:repo_name].blank? && !all_repos.include?(params[:repo_name])
            return nil # make sure it's valid
          elsif !params[:repo_name].blank?
            repo_name = params[:repo_name] # use valid repo name
          elsif !current_deploy.nil?
            repo_name = current_deploy.repo_nume # fall back to current deploy's repo
          else
            return nil # default fail
          end
          Octokit.repo("pardot/#{repo_name.downcase}")
        end
    end

    def all_repos
      %w[pardot pithumbs]
    end

    def repo_icon_map
      { "pardot"   => "cloud",
        "pithumbs" => "thumbs-up",
      }
    end

    def current_target
      @_current_target ||= \
        begin
          if !params[:target_name].blank?
            DeployTarget.where(name: params[:target_name]).first
          elsif !current_deploy.nil?
            current_deploy.deploy_target
          else
            nil
          end
        end
    end

    def current_deploy
      @_current_deploy ||= \
        begin
          if !params[:deploy_id].blank?
            deploy = Deploy.where(id: params[:deploy_id].to_i).first
            if deploy && params[:repo_name].blank?
              # set the repo name if it's not in the params hash already
              params[:repo_name] = deploy.repo_name
            end
            deploy
          else
            nil
          end
        end
    end

    # ----------------------------------------------------------------------
    # DATA
    def all_targets
      @_all_targets ||= DeployTarget.order(:name)
    end

    def get_recent_deploys_for_repos
      @last_repo_deploys = {}
      %w[pardot].each do |repo|
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
      path += \
        options.collect { |key,value| "#{key}=#{CGI.escape(value)}" }.join("&")
      path
    end

    def deploy_target_path(target, deploy=nil)
      path = "/deploy/target/#{target.name}?"
      deploy ||= current_deploy
      if deploy
        path += "repo_name=#{current_repo.name}&"
        path += "#{deploy.what}=#{deploy.what_details}"
      else
        raise 'Unknown path details...'
      end
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

    def github_diff_url(deploy1, deploy2)
      item1 = deploy1.branch? ? deploy1.sha : deploy1.what_details
      item2 = deploy2.branch? ? deploy2.sha : deploy2.what_details
      "#{github_url}/#{current_repo.full_name}/compare/#{item1}...#{item2}"
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
      "<span title='#{sha}' class='js-sha-expand' data-sha='#{sha}'>#{sha[0,8]}...</span>"
    end

    # ----------------------------------------------------------------------
    # PRINT
    def print_deploy_what(deploy)
      output = deploy_type_icon(deploy.what)
      output += " "
      if deploy.commit?
        output += sha_span(deploy.what_details)
      else
        output += deploy.what_details
      end
      output
    end

    def print_time(time)
      time.localtime.strftime("%m/%d/%y @ %l:%M %p")
    end

    def print_relative_time(time)
      time_delta = Time.now - time
      minutes = (time_delta / 60).round
      if minutes < 1
        seconds = time_delta.round
        "#{seconds} second#{seconds == 1 ? '' : 's'}"
      elsif minutes < 60
        "#{minutes} minute#{minutes == 1 ? '' : 's'}"
      else
        hours = minutes / 60.0
        "#{"%0.1f" % hours} hour#{hours == 1 ? '' : 's'}"
      end
    end

    def print_email(email)
      pieces = email.split("@")
      output = pieces[0]
      output += "<span class='muted'>@#{pieces[1]}</span>" if pieces[1]
      output
    end

  end
end
