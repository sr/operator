class ChefDelivery
  def initialize(config)
    @config = config
  end

  def checkin(request)
    if !@config.enabled_in?(request.environment)
      return ChefCheckinResponse.noop
    end

    if current_build.state != "success"
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != @config.master_branch
      if request.checkout_older_than?(@config.max_lock_age)
        notification.at_lock_age_limit(request.checkout, current_build)
      end

      return ChefCheckinResponse.noop
    end

    deploy = repo.current_deploy(request.environment, current_build.sha)

    if %w[success pending].include?(deploy.state)
      return ChefCheckinResponse.noop
    end

    if deploy.sha == request.checkout_sha
      return ChefCheckinResponse.noop
    end

    response = repo.create_pending_deploy(
      request.environment,
      @config.deploy_task_name,
      current_build
    )

    if response.success?
      return ChefCheckinResponse.deploy(response.deploy)
    end

    # TODO(sr) Log error
    return ChefCheckinResponse.noop
  end

  def deploy_started(request)
    repo.start_deployment(request.deploy_url)
    notification.deploy_started(request.deploy)
  end

  def deploy_completed(request)
    repo.complete_deployment(request.deploy_url)
    notification.deploy_completed(request.deploy)
  end

  private

  def notification
    @notification ||= ChefDeliveryNotification.new(
      @config.notifier,
      "https://git.dev.pardot.com",
      @config.repo_name,
      @config.chat_room_id
    )
  end

  def repo
    @repo ||= @config.github_repo
  end

  def current_build
    @current_build ||= repo.current_build(@config.master_branch)
  end
end
