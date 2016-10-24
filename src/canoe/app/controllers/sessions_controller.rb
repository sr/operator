class SessionsController < ApplicationController
  skip_before_action :require_oauth_authentication, only: [:new, :create, :failure]

  # OmniAuth doesn't send us a CSRF token
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
  end

  def create
    session.destroy

    user = AuthUser.find_or_create_by_omniauth(request.env["omniauth.auth"])
    if user && user.persisted?
      self.current_user = user
      redirect_to root_url
    else
      @errors = user.errors
      render action: "new"
    end
  end

  def destroy
    session.destroy
    redirect_to root_url
  end

  def failure
    session.destroy
    @auth_hash = request.env["omniauth.auth"]
    @failure_message = params[:message]
  end

  def phone_pairing
  end

  def create_phone_pairing
    response = current_user.phone.create_pairing(params[:pairing_phrase])

    unless response.success?
      flash[:alert] = "Salesforce Authenticator pairing request failed: #{response.error_message}"
    end

    redirect_to "/auth/phone"
  end

  def destroy_phone_pairing
    if !current_user.phone.new_record?
      current_user.phone.destroy!
    end

    redirect_to "/auth/phone"
  end
end
