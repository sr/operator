module Api
  class DeploysController < Controller
    before_action :require_project, only: [:create, :index, :latest]
    before_action :require_target, only: [:create, :index, :latest]
    before_action :require_deploy, only: [:show, :completed_server]
    before_action :require_email_authentication, only: [:create]

    def index
      @deploys = current_target.deploys
        .where(project_name: current_project.name)
        .order(id: :desc)
        .limit(10)
    end

    def create
      if !current_user.deploy_authorized?(current_project, current_target)
        render json: { error: true, message: "User #{current_user.email} is not authorized to deploy" }
        return
      end

      deploy_request = DeployRequest.new(
        current_project,
        current_target,
        current_user,
        params[:artifact_url],
        false,
        [],
        {}
      )

      render json: deploy_request.handle
    end

    def latest
      @deploy = current_target.last_deploy_for(current_project.name)
      if @deploy
        @results = params[:server].present? ? @deploy.results.for_server_hostnames(params[:server]) : @deploy.results
        render action: "show"
      else
        render json: { error: true, message: "Project #{current_project.name} hasn't been deployed to #{current_target.name}." }
      end
    end

    def show
      @deploy = current_deploy
      if @deploy
        @results = params[:server].present? ? @deploy.results.for_server_hostnames(params[:server]) : @deploy.results
        render
      else
        render json: { error: true, message: "Unable to find requested deploy." }
      end
    end

    def completed_server
      if current_deploy
        server = Server.find_by(hostname: params[:server])

        if !server
          render status: :not_found, json: { success: false }
          return
        end

        result = current_deploy.results.where(server: server).first

        if !result
          render status: :not_found, json: { success: false }
          return
        end

        result.update(stage: "completed")
      end

      current_deploy.check_completed_status!

      render json: { success: true }
    end
  end
end
