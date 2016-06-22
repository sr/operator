class ChefDelivery
  SUCCESS = "success".freeze
  FAILURE = "failure".freeze
  PENDING = "pending".freeze
  LOCKED  = "locked".freeze
  NONE = "none".freeze

  class Error < StandardError
  end

  Server = Struct.new(:datacenter, :environment, :hostname)

  def initialize(config)
    @config = config
  end

  def checkin(request, now = nil)
    now ||= Time.current

    Instrumentation.log(
      at: "chef",
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

    if current_build.branch != @config.master_branch
      return ChefCheckinResponse.noop
    end

    if request.checkout_sha == current_build.sha &&
       request.checkout_branch == current_build.branch
      return ChefCheckinResponse.noop
    end

    deploy = ChefDeploy.find_or_init_current(request.server, current_build)

    if deploy.state == PENDING
      return ChefCheckinResponse.noop
    end

    if request.checkout_branch != current_build.branch
      deploy.lock(
        notification,
        @config.chat_room_id(request.server),
        @config.max_lock_age,
        request,
        now
      )
      return ChefCheckinResponse.noop
    end

    if request.checkout_sha == deploy.sha
      return ChefCheckinResponse.noop
    end

    ChefCheckinResponse.deploy(deploy.start)
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
