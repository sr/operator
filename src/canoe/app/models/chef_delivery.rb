class ChefDelivery
  SUCCESS = "success".freeze
  FAILURE = "failure".freeze
  PENDING = "pending".freeze

  class Error < StandardError
  end

  def initialize(config)
    @config = config
  end

  def checkin(request)
    Instrumentation.log(
      at: "chef.checkin",
      branch: request.checkout_branch,
      sha: request.checkout_sha,
      current_build: current_build.to_json
    )

    if !@config.enabled_in?(request.hostname, request.environment)
      return ChefCheckinResponse.noop
    end

    if current_build.state != SUCCESS
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != @config.master_branch
      if (current_build.updated_at - Time.current) > @config.max_lock_age
        notification.at_lock_age_limit(
          @config.chat_room_id(request.hostname),
          request.hostname,
          request.checkout,
          current_build
        )
      end

      return ChefCheckinResponse.noop
    end

    deploy = ChefDeploy.find_current(request.environment, @config.master_branch)

    if [SUCCESS, PENDING].include?(deploy.state)
      return ChefCheckinResponse.noop
    end

    if deploy.sha == request.checkout_sha
      return ChefCheckinResponse.noop
    end

    deploy = ChefDeploy.create_pending(
      request.environment,
      @config.master_branch,
      current_build,
    )

    return ChefCheckinResponse.deploy(deploy)
  end

  def complete_deploy(request)
    status = request.success? ? SUCCESS : FAILURE
    ChefDeploy.complete(request.deploy_id, status)
    notification.deploy_completed(
      @config.chat_room_id(request.hostname),
      request.deploy,
      request.success?,
      request.error
    )
  end

  private

  def notification
    @notification ||= ChefDeliveryNotification.new(
      @config.notifier,
      @config.github_url,
      @config.repo_name
    )
  end

  def repo
    @repo ||= @config.github_repo
  end

  def current_build
    @current_build ||= repo.current_build(@config.master_branch)
  end
end
