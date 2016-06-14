class ChefDeploy < ActiveRecord::Base
  validates_inclusion_of :state, in: [
    ChefDelivery::PENDING,
    ChefDelivery::SUCCESS,
    ChefDelivery::FAILURE
  ]

  def self.create_pending(environment, branch, build)
    # TODO(sr) Refuse to create deploy for non-green build
    create!(
      branch: branch,
      build_url: build.url,
      environment: environment,
      sha: build.sha,
      state: ChefDelivery::PENDING
    )
  end

  def self.find_current(environment, branch)
    conditions = {environment: environment, branch: branch}
    deploys = where(conditions).order("id DESC")

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
  end
end
