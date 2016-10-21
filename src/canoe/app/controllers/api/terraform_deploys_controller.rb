module Api
  class TerraformDeploysController < Controller
    class << self
      attr_accessor :notifier
    end

    def create
      user = AuthUser.find_by_email(deploy_params[:user_email])

      if !user
        render json: { error: true, message: "No user with email #{deploy_params[:user_email].inspect}. You may need to sign into Canoe first." }
        return
      end

      build = TerraformBuild.new(params[:branch], params[:commit], params[:terraform_version])
      response = project.deploy(user, deploy_params[:estate], build)

      render json: response
    end

    def complete
      user = AuthUser.find_by_email(deploy_params[:user_email])

      if !user
        render json: { error: true, message: "No user with email #{deploy_params[:user_email].inspect}. You may need to sign into Canoe first." }
        return
      end

      response = project.complete_deploy(
        deploy_params[:deploy_id],
        deploy_params[:successful] == "true"
      )

      render json: response
    end

    private

    def project
      @project ||= TerraformProject.find!(TerraformDeploysController.notifier)
    end

    def deploy_params
      @deploy_params ||= params.permit(
        :deploy_id,
        :successful,
        :user_email,
        :estate,
        :user,
        :commit,
        :branch,
        :terraform_version
      )
    end
  end
end
