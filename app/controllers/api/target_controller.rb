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

  def lock
    output = Canoe::Locker.new.lock!(current_target, current_user)
    current_target.reload

    render json: {
      locked: current_target.is_locked?,
      output: output,
    }
  end

  def unlock
    output = Canoe::Locker.new.unlock!(current_target, current_user)
    current_target.reload

    render json: {
      locked: current_target.is_locked?,
      output: output,
    }
  end
end
