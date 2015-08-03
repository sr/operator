class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_filter :require_oauth_authentication

  private
  def require_oauth_authentication
    redirect_to oauth_url unless current_user.present?
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

  def oauth_url
    case Rails.env
    when "development" then "/auth/developer"
    else "/auth/google"
    end
  end

  def current_deploy
    @_current_deploy ||= \
      begin
        if !params[:id].blank?
          deploy = Deploy.where(id: params[:id].to_i).first
          if deploy && params[:repo_name].blank?
            # set the repo name if it's not in the params hash already
            params[:repo_name] = deploy.repo_name
          end
          deploy
        else
          nil
        end
      end
  end
  helper_method :current_deploy

  def current_repo
    @_current_repo ||= Octokit.repo("pardot/#{current_repo_name}")
  end
  helper_method :current_repo

  def current_repo_name
    @_current_repo_name ||= \
      begin
        repo_name = ""

        if params[:repo_name].blank? && current_deploy.nil?
          return nil # if we don't have anything, bail
        elsif !params[:repo_name].blank? && !all_repos.include?(params[:repo_name])
          return nil # make sure it's valid
        elsif !params[:repo_name].blank?
          repo_name = params[:repo_name] # use valid repo name
        elsif !current_deploy.nil?
          repo_name = current_deploy.repo_name # fall back to current deploy's repo
        else
          return nil # default fail
        end

        repo_name
      end
  end
  helper_method :current_repo_name

  def current_target
    @_current_target ||= \
      begin
        if !params[:target_name].blank?
          DeployTarget.where(name: params[:target_name]).first
        elsif !current_deploy.nil?
          current_deploy.deploy_target
        else
          nil
        end
      end
  end
  helper_method :current_target

  def all_targets
    @_all_targets ||= DeployTarget.order(:name)
  end
end
