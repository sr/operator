class ChefDeploy < ApplicationRecord
  validates_inclusion_of :state, in: [
    ChefDelivery::LOCKED,
    ChefDelivery::PENDING,
    ChefDelivery::SUCCESS,
    ChefDelivery::FAILURE
  ]

  def self.find_or_init_current(server, build)
    if build.tests_state != ChefDelivery::SUCCESS
      raise ChefDelivery::Error, "build is not successful: #{build.inspect}"
    end

    conditions = {
      build_url: build.tests_url,
      datacenter: server.datacenter,
      hostname: server.hostname
    }
    deploys = where(conditions).order("id DESC")

    if deploys.count > 0
      return deploys.first!
    end

    new(
      branch: build.branch,
      build_url: build.tests_url,
      environment: server.environment,
      datacenter: server.datacenter,
      hostname: server.hostname,
      sha: build.sha,
      state: ChefDelivery::NONE
    )
  end

  def self.complete(deploy_id, status)
    deploy = find(deploy_id)

    if deploy.state != ChefDelivery::PENDING
      raise ChefDelivery::Error, "unable to complete #{deploy.inspect}"
    end

    deploy.update!(state: status)
    deploy
  end

  # TODO(sr) rubocop:disable Metrics/ParameterLists
  # rubocop:disable Metrics/ParameterLists
  def lock(notifier, room_id, max_lock_age, request, now)
    self.state = ChefDelivery::LOCKED

    if last_notified_at.nil? || (now - last_notified_at) >= max_lock_age
      notifier.at_lock_age_limit(
        room_id,
        request.server,
        request.checkout,
        self,
      )
      self.last_notified_at = Time.current
    end

    save!
    self
  end

  def start
    if ![ChefDelivery::NONE, ChefDelivery::LOCKED, ChefDelivery::FAILURE].include?(state)
      raise ChefDelivery::Error, "bad start state transition: #{inspect}"
    end

    update!(state: ChefDelivery::PENDING)
    self
  end

  def redeploy
    new_deploy = ChefDeploy.new(
      branch: branch,
      build_url: build_url,
      environment: environment,
      datacenter: datacenter,
      hostname: hostname,
      sha: sha,
      state: ChefDelivery::NONE
    )
    new_deploy.start
  end

  def successful?
    state == ChefDelivery::SUCCESS
  end

  def build_id
    build_url.split("-").last
  end

  def server
    ChefDelivery::Server.new(datacenter, environment, hostname)
  end

  def to_json(*)
    attributes.to_json
  end
end
