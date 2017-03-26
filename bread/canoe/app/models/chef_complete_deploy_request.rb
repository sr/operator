class ChefCompleteDeployRequest
  def self.from_hash(request)
    new(
      request.fetch(:deploy_id),
      request.fetch(:success),
      request.fetch(:error_message, nil)
    )
  end

  def initialize(deploy_id, success, error_message)
    @deploy_id = deploy_id
    @success = success
    @error_message = error_message
  end

  attr_reader :deploy_id, :success, :error_message
end
