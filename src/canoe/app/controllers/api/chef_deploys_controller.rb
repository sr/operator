class Api::ChefDeploysController < Api::Controller
  def checkin
    request = ChefCheckinRequest.from_hash(payload)
    response = delivery.checkin(request)
    render json: response
  end

  def complete_deploy
    deploy = payload.fetch(:deploy)
    request = GithubRepository::Deploy.new(deploy)
    response = delivery.complete_deploy(request)
    render json: response
  end

  private

  def payload
    @payload ||= ActiveSupport::HashWithIndifferentAccess.new(
      JSON.parse(params[:payload])
    )
  end

  def delivery
    @delivery ||= ChefDelivery.new(
      ChefDeliveryConfig.new
    )
  end
end
