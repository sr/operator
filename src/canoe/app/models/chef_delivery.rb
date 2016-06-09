class ChefDelivery
  SUCCESS = "success".freeze
  FAILURE = "failure".freeze
  PENDING = "pending".freeze

  def initialize(config)
    @config = config
  end

  def checkin(request)
    Instrumentation.log(
      at: "chef.checkin",
      branch: request.checkout_branch,
      sha: request.checkout_sha
    )

    if !@config.enabled_in?(request.environment)
      return ChefCheckinResponse.noop
    end

    if current_build.state != SUCCESS
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != @config.master_branch
      if request.checkout_older_than?(@config.max_lock_age)
        notification.at_lock_age_limit(request.checkout, current_build)
      end

      return ChefCheckinResponse.noop
    end

    deploy = repo.current_deploy(
      request.environment,
      @config.master_branch,
      @config.deploy_task_name
    )

    if [SUCCESS, PENDING].include?(deploy.state)
      return ChefCheckinResponse.noop
    end

    if deploy.sha == request.checkout_sha
      return ChefCheckinResponse.noop
    end

    response = repo.create_pending_deploy(
      request.environment,
      @config.deploy_task_name,
      current_build,
      @config.master_branch,
    )

    if response.success?
      return ChefCheckinResponse.deploy(response.deploy)
    end

    # TODO(sr) Log error
    return ChefCheckinResponse.noop
  end

  def complete_deploy(request)
    status = request.success? ? SUCCESS : FAILURE
    response = repo.complete_deploy(request.deploy_url, status)

    if response.success?
      notification.deploy_completed(request.deploy, request.success?, request.error)
    else
      error = "Could not update GitHub deployment: #{response.error}"
      notification.deploy_completed(request.deploy, false, error)
    end
  end

  private

  def notification
    @notification ||= ChefDeliveryNotification.new(
      @config.notifier,
      @config.github_url,
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
