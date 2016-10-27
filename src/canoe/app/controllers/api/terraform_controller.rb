module Api
  class TerraformController < Controller
    before_action :require_email_authentication

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
        proto_request.deploy_id,
        proto_request.successful
      )

      render json: response.as_json
    end

    private

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
