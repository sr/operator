class TerraformDeployResponse
  def self.locked(deploy)
    new(deploy, "Terraform estate #{deploy.estate_name.inspect} is locked by #{deploy.user_name}")
  end

  def self.unknown_estate(name)
    new(nil, "Unknown Terraform estate: #{name.inspect}")
  end

  def self.success(deploy)
    new(deploy, "")
  end

  def initialize(deploy, error_message)
    @deploy_id = deploy.try(:id)
    @request_id = deploy.try(:request_id)
    @error_message = error_message
  end

  def to_json(_)
    JSON.dump(as_json)
  end

  def as_json
    proto_response.as_json
  end

  private

  def proto_response
    Canoe::TerraformDeployResponse.new(
      error: !@error_message.to_s.empty?,
      message: @error_message,
      deploy_id: @deploy_id.to_i,
      request_id: @request_id.to_s,
    )
  end
end
