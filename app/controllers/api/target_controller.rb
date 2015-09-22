class Api::TargetController < Api::Controller
  before_filter :require_target
  before_filter :require_user
  before_filter :require_repo, only: [:deploy]

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
    output = lock_target!
    current_target.reload

    render json: {
      locked: current_target.locked?,
      output: output,
    }
  end

  def unlock
    output = unlock_target!
    current_target.reload

    render json: {
      locked: current_target.locked?,
      output: output,
    }
  end

  def deploy
    if prov_deploy = build_provisional_deploy
      # start deploy on target
      deploy_response = deploy!(prov_deploy)

      response =
        if !deploy_response[:error] && deploy_response[:deploy]
          the_deploy = deploy_response[:deploy]
          { deployed: true,
              status_callback: "/api/status/deploy/#{the_deploy.id}",
          }
        else
          case deploy_response[:reason]
          when DEPLOYLOGIC_ERROR_NO_REPO # should be handled by guard above
            {error: true, message: "Unable to deploy. No repo given."}
          when DEPLOYLOGIC_ERROR_NO_TARGET # should be handled by guard above
            {error: true, message: "Unable to deploy. No target given."}
          when DEPLOYLOGIC_ERROR_NO_WHAT
            {error: true, message: "Unable to deploy. No branch, tag or commit given."}
          when DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY
            {error: true, message: "#{current_target.name} is currently locked."}
          when DEPLOYLOGIC_ERROR_INVALID_WHAT
            {error: true, message: "Invalid #{deploy_response[:what]} given."}
          else
            {error: true, message: "Unable to deploy. Unknown error."}
          end
        end
      render json: response
    else
      render json: {error: true, message: "Unknown deploy type: #{params[:what]}"}
    end
  end
end
