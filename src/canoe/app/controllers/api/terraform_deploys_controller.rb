module Api
  class TerraformDeploysController < Controller
    before_action :require_email_authentication

    class << self
      attr_accessor :notifier
    end

    def create
      build = TerraformBuild.new(params[:branch], params[:commit], params[:terraform_version])
      response = project.deploy(current_user, params[:estate], build)

      render json: response
    end

    def complete
      response = project.complete_deploy(
        params[:deploy_id],
        params[:successful] == "true"
      )

      render json: response
    end

    private

    def project
      @project ||= TerraformProject.find!(TerraformDeploysController.notifier)
    end
  end
end
