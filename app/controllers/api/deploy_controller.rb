class Api::DeployController < Api::Controller
  def completed_server
    if current_deploy
      server = Server.find_by_hostname(params[:server])
      if server && result = current_deploy.results.where(server: server).first
        result.update(status: "completed")
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

  def status
    if @deploy = current_deploy
      render
    else
      render json: {error: true, message: "Unable to find requested deploy."}
    end
  end
end
