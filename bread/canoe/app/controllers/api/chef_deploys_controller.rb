module Api
  class ChefDeploysController < Controller
    def checkin
      request = ChefCheckinRequest.from_hash(payload)
      response = delivery.checkin(request)
      render json: response
    end

    def complete_deploy
      request = ChefCompleteDeployRequest.from_hash(payload)
      response = delivery.complete_deploy(request)
      render json: response
    end

    def knife
      request = KnifeRequest.from_hash(payload)
      delivery.knife(request)
      head 200
    end

    private

    def payload
      @payload ||= ActiveSupport::HashWithIndifferentAccess.new(
        JSON.parse(params[:payload])
      )
    end

    def delivery
      @delivery ||= ChefDelivery.new(ChefDeliveryConfig.new)
    end
  end
end
