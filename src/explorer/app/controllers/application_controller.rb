class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_oauth_authentication
  around_action :log_context

  rescue_from Exception do |exception|
    Instrumentation.log_exception(exception)

    if !Rails.env.development?
      render file: "public/500.html", layout: false, status: 500
    else
      raise exception
    end
  end

  def sql_view
    "SQL".freeze
  end
  helper_method :sql_view

  def ui_view
    "UI".freeze
  end
  helper_method :ui_view

  protected

  def log_context
    data = { request_id: Instrumentation.request_id }

    if current_user
      data[:user_email] = current_user.email
    end

    Instrumentation.context(data) do
      yield
    end
  end

  private

  def append_info_to_payload(payload)
    if !current_user
      return
    end

    payload[:context] = { user_email: current_user.email }
  end

  def require_oauth_authentication
    unless current_user.present?
      session[:target_url] = target_url
      return redirect_to oauth_path
    end

    unless access_authorized?
      return redirect_to "/auth/unauthorized"
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = load_current_user
  end
  helper_method :current_user

  def load_current_user
    if !session[:user_id]
      return nil
    end

    created_at = session[:created_at]
    if created_at && Time.zone.at(created_at) >= Rails.application.config.x.session_ttl.ago
      return User.find_by_id(session[:user_id])
    end

    nil
  end

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

  # Returns true if this user is authorized to use Explorer, false otherwise.
  def access_authorized?
    full_access = Rails.application.config.x.full_access_ldap_group
    restricted_access = Rails.application.config.x.restricted_access_ldap_group
    if Rails.env.development?
      session[:group] = full_access
      return true
    end

    if current_user.new_record?
      return false
    end

    auth = Canoe::LDAPAuthorizer.new
    if auth.user_is_member_of_any_group?(current_user.uid, full_access)
      session[:group] = full_access
      true
    elsif auth.user_is_member_of_any_group?(current_user.uid, restricted_access)
      session[:group] = restricted_access
      true
    else
      false
    end
  end

  def target_url
    # After auth we'll want to reconfirm before submitting a POST
    request.method == "GET" ? request.original_url : request.referer
  end
end
