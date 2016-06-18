class ChefDeploy < ActiveRecord::Base
  validates_inclusion_of :state, in: [
    ChefDelivery::PENDING,
    ChefDelivery::SUCCESS,
    ChefDelivery::FAILURE
  ]

  def self.create_pending(server, branch, build)
    if build.state != ChefDelivery::SUCCESS
      raise ChefDelivery::Error,
        "can not create deploy for non-successful build: #{build.inspect}"
    end

    create!(
      branch: branch,
      build_url: build.url,
      environment: server.environment,
      datacenter: server.datacenter,
      hostname: server.hostname,
      sha: build.sha,
      state: ChefDelivery::PENDING
    )
  end

  def self.find_current(datacenter)
    deploys = where(datacenter: datacenter).order("id DESC")

    if deploys.empty?
      return ChefDeploy.new
    end

    deploys.first!
  end

  def self.complete(deploy_id, status)
    deploy = find(deploy_id)

    if deploy.state != ChefDelivery::PENDING
      raise ChefDelivery::Error, "unable to complete #{deploy.inspect}"
    end

    deploy.update!(state: status)
    deploy
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
