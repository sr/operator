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
end
