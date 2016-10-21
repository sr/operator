class TerraformDeployResponse
  def self.locked(deploy)
    new(nil, "Terraform estate #{deploy.estate_name.inspect} is locked by #{deploy.user_name}")
  end

  def self.unknown_estate(name)
    new(nil, "Unknown Terraform estate: #{name.inspect}")
  end

  def self.success(deploy)
    new(deploy.id, "")
  end

  def initialize(deploy_id, error_message)
    @deploy_id = deploy_id
    @error_message = error_message
  end

  def to_json(_)
    JSON.dump(
      error: !@error_message.to_s.empty?,
      message: @error_message,
      deploy_id: @deploy_id
    )
  end
end
