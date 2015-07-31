class Api::DeployController < Api::Controller
  def complete
    current_deploy.complete! if current_deploy
    render json: {success: true}
  end
end
