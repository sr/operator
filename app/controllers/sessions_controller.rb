# Session management controller for authenticating users with GitHub
class SessionsController < ApplicationController
  skip_before_action :require_oauth, only: [:new, :create]

  def create
    auth = request.env["omniauth.auth"]
    begin
      user = User.create_with_omniauth(auth)
      session[:user_id] = user.id
      return_to = session[:return_to] || root_url
      redirect_to return_to, notice: "Signed in as #{user.github_login}"
    rescue Exceptions::NotHerokaiError
      render plain: "Sorry, this application is only for members of the Heroku GitHub organization."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end
end
