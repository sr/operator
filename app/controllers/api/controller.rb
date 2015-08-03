class Api::Controller < ApplicationController
  skip_before_filter :require_oauth_authentication
  before_filter :require_api_authentication

  private
  def require_api_authentication
    if ENV["API_AUTH_TOKEN"].nil? || params[:api_token] != ENV["API_AUTH_TOKEN"]
      render json: { error: true, message: "Invalid auth token" }
      false
    end
  end

  # Overrides current_user from ApplicationController to do API-specific authentication
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = params[:user_email] && AuthUser.find_by_email(params[:user_email].to_s)
  end

  def require_api_target
    return if current_target
    render json: {error: true, message: "Invalid target specified."}
  end

  def require_api_user
    return if current_user
    render json: {error: true, message: "Invalid user specified."}
  end

  def require_api_repo
    return if current_repo
    render json: {error: true, message: "Invalid repo specified."}
  end
end
