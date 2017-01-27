module Api
  class TerraformController < ProtoController
    skip_before_action :require_api_authentication
    before_action :require_phone_authentication, only: [:create, :unlock]
    before_action :require_terraform_project

    def create
      build = TerraformBuild.new(
        proto_request.branch,
        proto_request.commit,
        proto_request.terraform_version
      )
      response = terraform_project.deploy(current_user, build)

      render json: response.as_json
    end

    def complete
      response = terraform_project.complete_deploy(
        proto_request.request_id,
        proto_request.successful
      )

      render json: response.as_json
    end

    def unlock
      response = terraform_project.unlock(current_user)
      render json: response.as_json
    end

    private

    def require_terraform_project
      unless terraform_project
        render json: TerraformDeployResponse.unknown_project(proto_request.project).as_json
      end
    end

    def phone_auth_action
      case params[:action]
      when "create"
        if terraform_project
          "Deploy terraform project #{terraform_project.name}"
        else
          "Terraform deploy"
        end
      when "unlock"
        if terraform_project
          "Unlock terraform project #{terraform_project.name}"
        else
          "Unlock terraform"
        end
      end
    end

    def terraform_project
      if defined?(@terraform_project)
        return @terraform_project
      end

      @terraform_project = TerraformProject.find_by(name: proto_request.project)
    end

    def proto_request
      @proto_request ||=
        case params[:action]
        when "create"
          Canoe::CreateTerraformDeployRequest.decode_json(request.body.read)
        when "complete"
          Canoe::CompleteTerraformDeployRequest.decode_json(request.body.read)
        when "unlock"
          Canoe::UnlockTerraformProjectRequest.decode_json(request.body.read)
        else
          raise UnhandleableRPCCall, params[:action]
        end
    end
  end
end