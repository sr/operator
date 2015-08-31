class Api::DeploysController < Api::Controller
  before_filter :require_target
  before_filter :require_repo

  def latest
    if @deploy = current_target.last_deploy_for(current_repo.name)
      render "api/deploy/status"
    else
      render json: {error: true, message: "Repo #{current_repo.name} hasn't been deployed to #{current_target.name}."}
    end
  end
end