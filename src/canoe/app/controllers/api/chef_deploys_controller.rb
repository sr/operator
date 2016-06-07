class Api::ChefDeploysController < Api::Controller
  def checkin
    config = ChefDeliveryConfig.new
    delivery = ChefDelivery.new(config)
    payload = JSON.parse(params[:payload])
    request = ChefCheckinRequest.from_hash(payload)
    response = delivery.checkin(request)
    render json: response
  end
end
