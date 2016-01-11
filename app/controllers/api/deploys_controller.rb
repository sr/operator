class Api::DeploysController < Api::Controller
  before_filter :require_repo, only: [:index, :latest]
  before_filter :require_target, only: [:index, :latest]
  before_filter :require_deploy, only: [:show, :completed_server]

  def index
    @deploys = current_target.deploys
      .where(repo_name: current_repo.name)
      .order(id: :desc)
      .limit(10)
  end

  def latest
    if @deploy = current_target.last_deploy_for(current_repo.name)
      @results = params[:server].present? ? @deploy.results.for_server_hostnames(params[:server]) : @deploy.results
      render action: "show"
    else
      render json: {error: true, message: "Repo #{current_repo.name} hasn't been deployed to #{current_target.name}."}
    end
  end

  def show
    if @deploy = current_deploy
      @results = params[:server].present? ? @deploy.results.for_server_hostnames(params[:server]) : @deploy.results
      render
    else
      render json: {error: true, message: "Unable to find requested deploy."}
    end
  end

  def completed_server
    if current_deploy
      server = Server.find_by_hostname(params[:server])
      if server && result = current_deploy.results.where(server: server).first
        result.update(stage: "completed")
      else
        render status: :not_found, json: {success: false}
        return
      end
    end

    current_deploy.check_completed_status!

    render json: {success: true}
  end

  private
end
