class ApplicationController < ActionController::Base
  SESSION_EXPIRATION = 8.hours

  protect_from_forgery with: :exception
  before_filter :require_oauth_authentication

  around_filter :log_context

  protected

  def log_context
    Instrumentation.context(request_id: Instrumentation.request_id) do
      yield
    end
  end

  def append_info_to_payload(payload)
    payload[:request_id] = Instrumentation.request_id
  end

  private

  def require_oauth_authentication
    redirect_to oauth_path unless current_user.present?
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = \
      if session[:user_id]
        if session[:created_at] && Time.at(session[:created_at]) >= SESSION_EXPIRATION.ago
          AuthUser.find_by_id(session[:user_id])
        else
          session.destroy
          nil
        end
      end
  end
  helper_method :current_user

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
    session[:created_at] = Time.now.to_i
  end

  def oauth_path
    case Rails.env
    when "development" then "/auth/developer"
    when "test" then "/auth/developer"
    else "/auth/ldap"
    end
  end
end
