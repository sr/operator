class Api::TargetController < Api::Controller
  before_filter :require_api_target
  before_filter :require_api_user

  def status
    if !current_target.user_can_deploy?(current_user)
      user_name = current_target.name_of_locking_user
      render json: {
        available: false,
        reason: "#{current_target.name} is currently locked by #{user_name}",
      }
    elsif current_target.active_deploy
      deploy = current_target.active_deploy
      deploy_name = "#{deploy.repo_name} #{deploy.what} #{deploy.what_details}"
      render json: {
        available: false,
        reason: "#{current_target.name} is currently running deploy of #{deploy_name}.",
      }
    else
      render json: {
        available: true
      }
    end
  end
end
