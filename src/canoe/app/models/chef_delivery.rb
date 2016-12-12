class ChefDelivery
  PROJECT = "chef".freeze
  SUCCESS = GithubRepository::SUCCESS
  FAILURE = GithubRepository::FAILURE
  PENDING = GithubRepository::PENDING
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
      current_build: current_build.to_json,
      server: request.server.to_json,
    )

    if !@config.enabled?(request.server)
      return ChefCheckinResponse.noop
    end

    if current_build.tests_state != SUCCESS
      return ChefCheckinResponse.noop
    end

    if current_build.branch != @config.master_branch
      return ChefCheckinResponse.noop
    end

    deploy = ChefDeploy.find_or_init_current(request.server, current_build)

    if deploy.state == PENDING
      return ChefCheckinResponse.noop
    end

    if request.checkout_sha == current_build.sha &&
       request.checkout_branch == current_build.branch
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

    if deploy.state == NONE
      return ChefCheckinResponse.deploy(deploy.start)
    end

    if request.checkout_sha == deploy.sha
      return ChefCheckinResponse.noop
    end

    if deploy.successful?
      ChefCheckinResponse.deploy(deploy.redeploy)
    else
      ChefCheckinResponse.deploy(deploy.start)
    end
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

  def knife(request)
    if !@config.knife_notifications_enabled?(request.server)
      return
    end

    if request.command[0] == "help"
      return
    end

    if request.command[0] == "search"
      return
    end

    if request.command[0, 2] == %w[node show]
      return
    end

    if request.command[0, 2] == %w[node list]
      return
    end

    if request.command[0, 2] == %w[pd sync]
      return
    end

    if request.command[0, 3] == %w[node from file]
      return
    end

    notification.knife_command(
      @config.chat_room_id(request.server),
      request.server,
      request.command
    )
  end

  private

  def notification
    @notification ||= ChefDeliveryNotification.new(
      @config.notifier,
      Canoe.config.github_url,
      Canoe.config.chef_repository_name
    )
  end

  def current_build
    @current_build ||= @config.github_repo.commit_status(@config.master_branch)
  end
end
