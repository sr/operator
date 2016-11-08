class ApplicationController < ActionController::Base
  SESSION_EXPIRATION = 8.hours

  force_ssl unless: :no_ssl_ok?

  include PaginationHelper

  protect_from_forgery with: :exception

  before_action :require_oauth_authentication

  around_action :log_context

  rescue_from Exception do |exception|
    if !Rails.env.test? && !Rails.env.development?
      Instrumentation.log_exception(exception)
      render file: "public/500.html", layout: false, status: 500
    else
      raise exception
    end
  end

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

  def no_ssl_ok?
    Rails.env.development? || Rails.env.test? || request.ip =~ /\A(10\.|127\.)/
  end

  def require_oauth_authentication
    redirect_to oauth_path unless current_user.present?
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = \
      if session[:user_id]
        if session[:created_at] && Time.at(session[:created_at]) >= SESSION_EXPIRATION.ago
          AuthUser.find_by(id: session[:user_id])
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

  def current_result
    return @current_result if defined?(@current_result)
    @current_result = current_deploy.results.for_server_hostname(params[:hostname] || params[:server_hostname])
  end
  helper_method :current_result

  def current_deploy
    return @current_deploy if defined?(@current_deploy)
    @current_deploy =
      if id = params[:deploy_id] || params[:id]
        deploy = Deploy.find_by(id: id.to_i)
        if deploy && params[:project_name].blank?
          # set the project name if it's not in the params hash already
          params[:project_name] = deploy.project_name
        end
        deploy
      end
  end
  helper_method :current_deploy

  def current_project
    return @current_project if defined?(@current_project)
    @current_project =
      if params[:project_name].present?
        Project.find_by(name: params[:project_name].to_s)
      elsif params[:repo_name].present? # backwards compatibility
        Project.find_by(name: params[:repo_name].to_s)
      elsif params[:name].present?
        Project.find_by(name: params[:name].to_s)
      elsif current_deploy
        Project.find_by(name: current_deploy.project_name)
      end
  end
  helper_method :current_project

  def current_target
    return @current_target if defined?(@current_target)
    @current_target =
      if params[:target_name].present?
        DeployTarget.enabled.where(name: params[:target_name].to_s).first
      elsif params[:name].present?
        DeployTarget.enabled.where(name: params[:name].to_s).first
      elsif current_deploy
        current_deploy.deploy_target
      end
  end
  helper_method :current_target

  def all_targets
    @all_targets ||= DeployTarget.enabled.order(:production, :name)
  end
  helper_method :all_targets

  def all_projects
    @all_projects ||= Project.enabled.order(:name)
  end
  helper_method :all_projects

  def require_project
    return if current_project
    raise ActiveRecord::RecordNotFound, "no project found"
  end

  def require_target
    return if current_target
    raise ActiveRecord::RecordNotFound, "no target found"
  end

  def require_deploy
    return if current_deploy
    raise ActiveRecord::RecordNotFound, "no deploy found"
  end

  def require_result
    return if current_result
    raise ActiveRecord::RecordNotFound, "no result found"
  end

  def require_deploy_acl_satisfied
    if !current_user
      raise "No current_user"
    end

    if current_user.deploy_authorized?(current_project, current_target)
      true
    else
      render template: "application/not_authorized_for_deploy", status: :unauthorized
    end
  end

  def build_provisional_deploy
    Build.from_artifact_url(current_project, params[:artifact_url])
  end

  def deploy_workflow_for(deploy)
    @deploy_workflows ||= {}
    @deploy_workflows[deploy] ||= DeployWorkflow.new(deploy: deploy)
  end
  helper_method :deploy_workflow_for
end
