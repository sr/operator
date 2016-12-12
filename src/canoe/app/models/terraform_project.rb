class TerraformProject < ActiveRecord::Base
  BREAD = "Pardot/bread".freeze

  belongs_to :project
  has_many :terraform_deploys

  cattr_accessor :required_version do
    Pathname("../../../config/terraform-version")
      .expand_path(__FILE__).read.chomp
  end

  cattr_accessor :notifier do
    HipchatNotifier.new
  end

  def deploy(user, build)
    if build.terraform_version != required_version
      error = "Terraform version #{build.terraform_version} does not " \
        "match required version: #{required_version}"
      return TerraformDeployResponse.new(nil, error)
    end

    commit_status = github_repository.commit_status(build.commit)

    if commit_status.compare_status == GithubRepository::BEHIND
      message = "Current branch #{build.branch.inspect} is not " \
        "up to date. Please merge master before continuing"
      return TerraformDeployResponse.new(nil, message)
    end

    if commit_status.compliance_state != GithubRepository::SUCCESS
      message = "Current compliance status #{commit_status.compliance_state.inspect} for " \
        "#{commit_status.branch}@#{commit_status.sha[0, 7]} is not successful. " \
        "See #{commit_status.compliance_url} for details"
      return TerraformDeployResponse.new(nil, message)
    end

    deploy = transaction do
      if terraform_deploys.pending.count > 0
        return TerraformDeployResponse.locked(terraform_deploys.first!)
      end

      terraform_deploys.create!(
        auth_user: user,
        branch_name: build.branch,
        commit_sha1: build.commit,
        terraform_version: build.terraform_version,
        request_id: SecureRandom.uuid,
      )
    end

    notification.deploy_started(deploy)

    TerraformDeployResponse.success(deploy)
  end

  def complete_deploy(request_id, successful)
    deploy = TerraformDeploy.find_by(request_id: request_id)

    unless deploy
      return TerraformDeployResponse.new(nil, "No such deploy request: #{request_id.inspect}")
    end

    unless deploy.completed_at.nil?
      return TerraformDeployResponse.new(deploy.id, "Deploy is already complete")
    end

    deploy.update!(completed_at: Time.current, successful: successful)
    notification.deploy_complete(deploy)

    TerraformDeployResponse.success(deploy)
  end

  def unlock(user)
    deploy = transaction do
      deploy = terraform_deploys.pending.first

      if !deploy
        return TerraformDeployResponse.new(nil, "Terraform project #{name.inspect} is not locked")
      end

      deploy.update!(completed_at: Time.current, successful: false)
      deploy
    end

    notification.unlock(user, deploy)
  end

  def deploy_notifications
    project.deploy_notifications
  end

  private

  def github_repository
    @github_repository ||= GithubRepository.new(Canoe.config.github_client, BREAD)
  end

  def notification
    TerraformNotification.new(notifier, room_ids)
  end

  def room_ids
    deploy_notifications.map(&:hipchat_room_id)
  end
end
