class ChefDelivery
  def initialize(config)
    @config = config
  end

  def checkin(request)
    if !@config.enabled_in?(request.environment)
      return ChefCheckinResponse.noop
    end

    if request.checkout_sha1 == current_deploy.sha1
      return ChefCheckinResponse.noop
    end

    if current_build.red?
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != @config.master_branch
      if request.checkout_older_than?(@config.max_lock_age)
        notification.at_lock_age_limit(request.checkout)
      end

      return ChefCheckinResponse.noop
    end

    deploy = GitHubDeployment.new(github, @config.repo_name)
    response = deploy.create

    if response.success?
      return ChefCheckinResponse.deploy(response.deploy)
    end

    # TODO(sr) Log error
    return ChefCheckinResponse.noop
  end

  def deployment_started(request)
    deploy = ChefGitHubDeploy.new(github, @config.repo_name)
    deploy.start(request.deploy_id)
    notification.deploy_started(request.deploy)
  end

  def deployment_completed(request)
    deploy = GitHubDeploy.new(github, @config.repo_name)
    deploy.complete(request.deploy_id)
    notification.deploy_started(request.deploy)
  end

  private

  def notification
    @notifier ||= ChefDeliveryNotification.new(
      @config.chat_token,
      @config.chat_room_id,
      @config.repo_name,
      @config.master_branch,
    )
  end

  def github
    @github ||= Octokit::Client.new(access_token: @config.github_token)
  end

  def current_build
    @current_build ||= fetch_current_build
  end

  def current_deploy
    @current_deploy ||= fetch_current_deploy
  end

  def fetch_current_build
    response = Octokit.combined_statuses(@repo_name, @master_branch)
  end
end
