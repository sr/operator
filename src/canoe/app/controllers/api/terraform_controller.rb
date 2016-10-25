module Api
  class TerraformController < Controller
    skip_before_action :require_api_authentication
    before_action :require_email_authentication
    before_action :require_phone_authentication, only: [:create]

    class << self
      attr_accessor :notifier
    end

    def create
      build = TerraformBuild.new(
        proto_request.branch,
        proto_request.commit,
        proto_request.terraform_version
      )
      response = project.deploy(current_user, proto_request.estate, build)

      render json: response.as_json
    end

    def complete
      response = project.complete_deploy(
        proto_request.request_id,
        proto_request.successful
      )

      render json: response.as_json
    end

    private

    def require_phone_authentication
      if !current_user.phone.authenticate
        render status: 401, json: { error: true, message: "Phone authentication required" }
        return false
      end
    end

    def current_user
      @terraform_current_user ||= AuthUser.find_by_email(proto_request.user_email)
    end

    def proto_request
      @proto_request ||=
        case params[:action]
        when "create"
          Canoe::CreateTerraformDeployRequest.decode_json(request.body.read)
        when "complete"
          Canoe::CompleteTerraformDeployRequest.decode_json(request.body.read)
        else
          raise "Unable to handle RPC call: #{params[:action].inspect}"
        end
    end

    def project
      @project ||= TerraformProject.find!(TerraformController.notifier)
    end
  end
end
