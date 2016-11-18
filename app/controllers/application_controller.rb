# Top level controller class that every controller inherits from
class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception
  helper_method :current_user
  before_action :require_oauth

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    @current_user = nil
    session[:user_id] = nil
    return nil
  end

  def current_github_login
    current_user.github_login
  end

  def require_oauth
    return true if current_user.present?
    session[:return_to] = request.original_url
    redirect_to "/auth/github"
  end

  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.env["action_dispatch.request_id"]
  end
end
