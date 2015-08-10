class ApplicationController < ActionController::Base
  include Canoe::DeployLogic
  include PaginationHelper

  protect_from_forgery with: :null_session

  before_filter :require_oauth_authentication

  private
  def require_oauth_authentication
    redirect_to oauth_path unless current_user.present?
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id] && AuthUser.find_by_id(session[:user_id])
  end
  helper_method :current_user

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
  end

  def oauth_path
    case Rails.env
    when "development" then "/auth/developer"
    when "test" then "/auth/developer"
    else "/auth/google"
    end
  end

  def current_deploy
    return @current_deploy if defined?(@current_deploy)
    @current_deploy =
      if params[:id].present?
        deploy = Deploy.find_by_id(params[:id].to_i)
        if deploy && params[:repo_name].blank?
          # set the repo name if it's not in the params hash already
          params[:repo_name] = deploy.repo_name
        end
        deploy
      end
  end
  helper_method :current_deploy

  def current_repo
    return @current_repo if defined?(@current_repo)
    @current_repo = current_repo_name && Repo.new(current_repo_name)
  end
  helper_method :current_repo

  def current_repo_name
    return @current_repo_name if defined?(@current_repo_name)
    @current_repo_name =
      if params[:repo_name].present? && all_repos.include?(params[:repo_name])
        params[:repo_name]
      elsif params[:name].present? && all_repos.include?(params[:name])
        params[:name]
      elsif current_deploy
        current_deploy.repo_name
      end
  end
  helper_method :current_repo_name

  def current_target
    return @current_target if defined?(@current_target)
    @current_target =
      if params[:target_name].present?
        DeployTarget.find_by_name(params[:target_name].to_s)
      elsif params[:name].present?
        DeployTarget.find_by_name(params[:name].to_s)
      elsif current_deploy
        current_deploy.deploy_target
      end
  end
  helper_method :current_target

  def all_targets
    @all_targets ||= DeployTarget.order(:name)
  end
  helper_method :all_targets

  def all_repos
    %w[pardot pithumbs realtime-frontend workflow-stats]
  end
  helper_method :all_repos

  def require_repo
    return if current_repo
    # TODO: Remove the need for this
    raise ActiveRecord::RecordNotFound.new("no repository with name '#{current_repo_name}'")
  end

  def require_target
    return if current_target
    # TODO: Remove the need for this
    raise ActiveRecord::RecordNotFound.new("no target found")
  end
end
