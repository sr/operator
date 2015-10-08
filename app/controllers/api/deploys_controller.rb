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
      render action: "show"
    else
      render json: {error: true, message: "Repo #{current_repo.name} hasn't been deployed to #{current_target.name}."}
    end
  end

  def show
    if @deploy = current_deploy
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
        # TODO: Remove this section of code when sync_scripts are no longer used
        servers = current_deploy.finished_servers
        servers << params[:server]
        servers.compact!
        current_deploy.update_attribute(:completed_servers, servers.join(","))
      end
    end

    current_deploy.check_completed_status!

    render json: {success: true}
  end
end
