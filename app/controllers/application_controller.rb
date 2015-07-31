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
end
