class SessionsController < ApplicationController
  skip_before_action :require_oauth_authentication, only: [:new, :create, :failure, :unauthorized]

  # OmniAuth doesn't send us a CSRF token
  skip_before_action :verify_authenticity_token, only: [:create]

  def new; end

  def create
    target_url = session[:target_url]
    session.destroy

    user = User.find_or_create_by_omniauth(request.env["omniauth.auth"])
    if user && user.persisted?
      self.current_user = user
      redirect_to target_url.blank? ? root_url : target_url
    else
      @errors = user.errors
      render action: "new"
    end
  end

  def destroy
    session.destroy
    redirect_to root_url
  end

  def unauthorized; end

  def failure
    session.destroy
    @auth_hash = request.env["omniauth.auth"]
    @failure_message = params[:message]
  end
end
