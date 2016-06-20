class ChefDelivery
  SUCCESS = "success".freeze
  FAILURE = "failure".freeze
  PENDING = "pending".freeze

  class Error < StandardError
  end

  Server = Struct.new(:datacenter, :environment, :hostname)

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

    if !@config.enabled?(request.server)
      return ChefCheckinResponse.noop
    end

    if current_build.state != SUCCESS
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != @config.master_branch
      if (Time.current - current_build.updated_at) > @config.max_lock_age
        notification.at_lock_age_limit(
          @config.chat_room_id(request.server),
          request.server,
          request.checkout,
          current_build
        )
      end

      return ChefCheckinResponse.noop
    end

    deploy = ChefDeploy.find_current(request.server.datacenter)

    if deploy.state == PENDING
      return ChefCheckinResponse.noop
    end

    if request.checkout_sha == current_build.sha
      return ChefCheckinResponse.noop
    end

    new_deploy = ChefDeploy.create_pending(
      request.server,
      @config.master_branch,
      current_build
    )

    ChefCheckinResponse.deploy(new_deploy)
  end

  def complete_deploy(request)
    status = request.success ? SUCCESS : FAILURE
    deploy = ChefDeploy.complete(request.deploy_id, status)
    notification.deploy_completed(
      @config.chat_room_id(deploy.server),
      deploy,
      request.error_message
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
