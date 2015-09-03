class DeploysController < ApplicationController
  before_filter :require_repo
  before_filter :require_target, only: [:new, :create]
  before_filter :require_no_active_deploy, only: [:new, :create]

  def select_target
    if @prov_deploy = build_provisional_deploy
      @targets = DeployTarget.order(:name)
    else
      render_invalid_provisional_deploy
    end
  end

  def new
    if @prov_deploy = build_provisional_deploy
      @previous_deploy = current_target.last_successful_deploy_for(current_repo.name)
      @committers = committers_for_compare(@previous_deploy, @prov_deploy)
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
      else # error
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
    else
      render_invalid_provisional_deploy
    end
  end

  def complete
    current_deploy.complete! if current_deploy
    redirect_to repo_deploy_path(current_repo.name, current_deploy.id)
  end

  def cancel
    current_deploy.cancel! if current_deploy
    redirect_to repo_deploy_path(current_repo.name, current_deploy.id)
  end

  private
  def require_no_active_deploy
    unless current_target.active_deploy.nil?
      flash[:notice] = "There is currently a deploy in progress."
      redirect_to :back
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
end
