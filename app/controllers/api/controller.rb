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
end
