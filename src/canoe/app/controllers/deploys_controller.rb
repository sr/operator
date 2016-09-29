class DeploysController < ApplicationController
  before_action :require_project
  before_action :require_target, only: [:new, :create, :index]
  before_action :require_deploy, only: [:show, :complete, :cancel, :force_to_complete]
  before_action :require_deploy_acl_satisfied, only: [:new, :create, :index, :show, :complete, :cancel, :force_to_complete]
  before_action :require_no_active_deploy, only: [:new, :create]
  before_action :require_no_active_lock, only: [:new, :create]

  def index
    all_deploys = current_target.deploys
      .where(project_name: current_project.name)
      .reverse_chronological

    @total_deploys = all_deploys.count
    @deploys = all_deploys
      .offset(pagination_page_size * (current_page - 1))
      .limit(pagination_page_size)
  end

  def select_target
    @prov_deploy = build_provisional_deploy

    if @prov_deploy
      @targets = DeployTarget.enabled.order(:production, :name)
    else
      render_invalid_provisional_deploy
    end
  end

  def new
    @prov_deploy = build_provisional_deploy

    if @prov_deploy
      @previous_deploy = current_target.last_successful_deploy_for(current_project.name)
      @committers = committers_for_compare(@previous_deploy, @prov_deploy)
      @servers = current_target.servers(project: current_project).enabled
      @server_hostnames = @servers.order(:hostname).pluck(:hostname)

      @tag_to_servers = {}
      @servers.includes(:server_tags).each do |server|
        server.server_tags.each do |tag|
          @tag_to_servers[tag] ||= []
          @tag_to_servers[tag] << server
        end
      end
      @tag_to_servers = @tag_to_servers.sort_by { |tag, _| tag.name }
    else
      render_invalid_provisional_deploy
    end
  end

  def show
    @deploy = Deploy.includes(results: [:server]).find(params[:id])
    @deploy.check_completed_status!

    @watching = params[:watching].present?
    @previous_deploy = current_target.previous_successful_deploy(current_deploy)
    @show_full_logs = (params[:show_full] == "1")

    @deploy_results = @deploy.results.includes(:server).sort_by_server_hostname
  end

  def create
    prov_deploy = build_provisional_deploy

    if !prov_deploy
      return render_invalid_provisional_deploy
    end

    deploy_request = DeployRequest.new(
      current_project,
      current_target,
      current_user,
      params
    )
    deploy_response = deploy_request.handle(prov_deploy)

    if deploy_response[:error]
      message = DeployRequest.error_message(deploy_response[:reason])
      flash[:notice] = message
      redirect_to :back
      return
    end

    the_deploy = deploy_response[:deploy]
    redirect_to project_deploy_path(current_project.name, the_deploy.id, watching: "1")
  end

  def force_to_complete
    deploy_workflow_for(current_deploy).fail_deploy_on_initiated_servers
    redirect_to project_deploy_path(current_project.name, current_deploy.id, watching: "1")
  end

  def pick_new_restart_servers
    deploy_workflow_for(current_deploy).pick_new_restart_servers
    redirect_to project_deploy_path(current_project.name, current_deploy.id, watching: "1")
  end

  def complete
    current_deploy.complete! if current_deploy
    redirect_to project_deploy_path(current_project.name, current_deploy.id)
  end

  def cancel
    deploy_workflow_for(current_deploy).fail_deploy_on_incomplete_servers
    current_deploy.cancel!
    redirect_to project_deploy_path(current_project.name, current_deploy.id)
  end

  private

  def require_no_active_deploy
    unless current_target.active_deploy(current_project).nil?
      flash[:notice] = "There is currently a deploy in progress."
      redirect_to :back
    end
  end

  def require_no_active_lock
    unless current_target.user_can_deploy?(current_project, current_user)
      flash[:alert] = "The current target and project are locked by another user."
      redirect_to project_url(current_project)
    end
  end

  def committers_for_compare(item1, item2)
    if !item1.respond_to?(:sha) || !item2.respond_to?(:sha)
      return []
    end

    compare = GithubComparison.new(
      current_project.repository,
      item1.sha,
      item2.sha,
    )
    compare.committers
  end

  def render_invalid_provisional_deploy
    render status: :unprocessable_entity, text: "Unknown deploy type: #{params[:what]}"
  end
end
