class Api::DeployController < Api::Controller
  def complete
    current_deploy.complete! if current_deploy
    render json: {success: true}
  end

  def completed_server
    if current_deploy
      # TODO: This likely suffers from a race condition. Can we split out
      # `completed_servers` into a table instead? -@alindeman
      servers = current_deploy.finished_servers
      servers << params[:server]
      servers.compact!
      current_deploy.update_attribute(:completed_servers, servers.join(","))
    end

    render json: {success: true}
  end
end
