class DeploysController < ApplicationController
  before_filter :require_repo
  before_filter :require_target, only: [:new, :create, :index]
  before_filter :require_deploy, only: [:show, :complete, :cancel, :force_to_complete]
  before_filter :require_no_active_deploy, only: [:new, :create]
  before_filter :require_no_active_lock, only: [:new, :create]

  def index
    all_deploys = current_target.deploys
      .where(repo_name: current_repo.name)
      .reverse_chronological

    @total_deploys = all_deploys.count
    @deploys = all_deploys
      .offset(pagination_page_size * (current_page - 1))
      .limit(pagination_page_size)
  end

  def select_target
    if @prov_deploy = build_provisional_deploy
      @targets = DeployTarget.enabled.order(:name)
    else
      render_invalid_provisional_deploy
    end
  end

  def new
    if @prov_deploy = build_provisional_deploy
      @previous_deploy = current_target.last_successful_deploy_for(current_repo.name)
      @committers = committers_for_compare(@previous_deploy, @prov_deploy)

      # TODO: Remove strategy once pull-based deployment is fully rolled out.
      #
      # TODO: Use server_ids instead of server hostnames once pull-based
      # deployment is fully rolled out.
      @server_hostnames = current_target.servers(repo: current_repo).enabled.pluck(:hostname)
      if current_target.script_path.present?
        @server_hostnames.concat(Rails.application.config.deployment.strategy.list_servers(current_target, current_repo.name))
      end
      @server_hostnames.sort!

      @tags = ServerTag.includes(:servers).select { |tag| tag.servers.any? }
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
  end

  def create
    if prov_deploy = build_provisional_deploy
      deploy_response = deploy!(prov_deploy)
      if !deploy_response[:error] && deploy_response[:deploy]
        the_deploy = deploy_response[:deploy]
        redirect_to repo_deploy_path(current_repo.name, the_deploy.id, watching: "1")
      else
        render_deploy_error(deploy_response)
      end
    else
      render_invalid_provisional_deploy
    end
  end

  def force_to_complete
    deploy_workflow_for(current_deploy).fail_deploy_on_initiated_servers
    redirect_to repo_deploy_path(current_repo.name, current_deploy.id)
  end

  def complete
    current_deploy.complete! if current_deploy
    redirect_to repo_deploy_path(current_repo.name, current_deploy.id)
  end

  def cancel
    deploy_workflow_for(current_deploy).fail_deploy_on_incomplete_servers
    current_deploy.cancel!
    redirect_to repo_deploy_path(current_repo.name, current_deploy.id)
  end

  private
  def require_no_active_deploy
    unless current_target.active_deploy(current_repo).nil?
      flash[:notice] = "There is currently a deploy in progress."
      redirect_to :back
    end
  end

  def require_no_active_lock
    unless current_target.user_can_deploy?(current_repo, current_user)
      flash[:alert] = "The current target and repository are locked by another user."
      redirect_to repo_url(current_repo)
    end
  end

  # TODO: Extract these to a different place -@alindeman
  def committers_for_compare(item1, item2)
    output = commits_for_compare(item1, item2)
    return [] if output.nil?

    # we have to work around stevie's busted git setup (facepalm)
    # gather some sort of author from each commit
    authors = \
      output.commits.collect do |commit|
      commit.author || commit.committer || commit.commit.author || commit.commit.committer
    end
    # try to pull out the username or email (yes, stevie's email is in the name field)
    authors.collect do |author|
      author.try(:login) || author.try(:name)
    end.uniq.sort
  rescue Octokit::NotFound
    []
  end

  def commits_for_compare(item1, item2)
    return unless item1 && item2
    Octokit.compare(current_repo.full_name, item1.sha, item2.sha)
  end

  def render_invalid_provisional_deploy
    render status: :unprocessable_entity, text: "Unknown deploy type: #{params[:what]}"
  end

  def render_deploy_error(deploy_response)
    # missing pieces
    missing_error_codes = \
      [DEPLOYLOGIC_ERROR_NO_REPO, DEPLOYLOGIC_ERROR_NO_TARGET, DEPLOYLOGIC_ERROR_NO_WHAT]
    if missing_error_codes.include?(deploy_response[:reason])
      flash[:notice] = "We did not have everything needed to deploy. Try again."
      redirect_to :back
    end

    # check for invalid
    if deploy_response[:reason] == DEPLOYLOGIC_ERROR_INVALID_WHAT
      flash[:notice] = "Sorry, it appears you specified an unknown #{deploy_response[:what]}."
      redirect_to :back
    end

    # check for locked target, allow user who has it locked to deploy again
    if deploy_response[:reason] == DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY
      flash[:notice] = "Sorry, it looks like #{current_target.name} is locked."
      redirect_to :back
    end
  end
end
