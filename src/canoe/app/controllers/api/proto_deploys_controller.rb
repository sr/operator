module Api
  class ProtoDeploysController < ProtoController
    before_action :require_project
    before_action :require_target

    def create
      if !current_user.deploy_authorized?(current_project, current_target)
        render json: { error: true, message: "User #{current_user.email} is not authorized to deploy" }
        return
      end

      deploy_request = DeployRequest.new(
        current_project,
        current_target,
        current_user,
        proto_request.artifact_url,
        false,
        [],
        {}
      )

      deploy_response = deploy_request.handle

      render json: deploy_response.as_proto_json
    end

    private

    def current_project
      Project.where(name: proto_request.project).first
    end

    def current_target
      DeployTarget.enabled.where(name: proto_request.target_name).first
    end

    def proto_request
      @proto_request ||=
        case params[:action]
        when "create"
          Canoe::CreateDeployRequest.decode_json(request.body.read)
        else
          raise "Unable to handle RPC call: #{params[:action].inspect}"
        end
    end
  end
end
