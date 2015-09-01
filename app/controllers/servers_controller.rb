class ServersController < ApplicationController
  def index
    @servers = Server.order(hostname: :asc).includes(:deploy_target, :repos)
  end

  def new
    @server = Server.new
  end

  def create
    @server = Server.new(server_params)
    if @server.save
      redirect_to servers_path, notice: "Server #{@server.hostname} added"
    else
      render action: "new"
    end
  end

  def edit
    @server = Server.find(params[:id])
  end

  def update
    @server = Server.find(params[:id])
    if @server.update(server_params)
      redirect_to servers_path, notice: "Server #{@server.hostname} updated"
    else
      render action: "edit"
    end
  end

  def destroy
    @server = Server.find(params[:id])
    if @server.destroy
      redirect_to servers_path, notice: "Server #{@server.hostname} deleted"
    else
      redirect_to servers_path, alert: "Server #{@server.hostname} not deleted"
    end
  end

  private
  def server_params
    params.require(:server).permit(:hostname, :enabled, :deploy_target_id, :repo_ids => [])
  end
end
