class ServersController < ApplicationController
  def index
    @servers = Server.order(hostname: :asc)
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

  private
  def server_params
    params.require(:server).permit(
      :hostname, :enabled,
      :deploy_scenarios_attributes => [:id, :deploy_target_id, :repo_id, :_destroy]
    )
  end
end
