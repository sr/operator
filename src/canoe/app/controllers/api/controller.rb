module Api
  class Controller < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_oauth_authentication
    before_action :require_api_authentication

    private

    def require_api_authentication
      provided_api_token = request.headers["X-Api-Token"].presence || params[:api_token].presence
      if ENV["API_AUTH_TOKEN"].nil? || provided_api_token.nil? || !Rack::Utils.secure_compare(ENV["API_AUTH_TOKEN"], provided_api_token)
        render status: 401, json: { error: true, message: "Invalid auth token" }
        false
      end
    end

    def require_email_authentication
      unless current_user
        message = "No user with email #{params[:user_email].inspect}. " \
          "You may need to sign into Canoe first."
        render status: 401, json: { error: true, message: message }

        return false
      end

      true
    end

    # Overrides current_user from ApplicationController to do API-specific authentication
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = params[:user_email] && AuthUser.find_by_email(params[:user_email].to_s)
    end

    def require_target
      return if current_target
      render status: 404, json: { error: true, message: "Invalid target specified." }
    end

    def require_user
      return if current_user
      render status: 400, json: { error: true, message: "Invalid user specified." }
    end

    def require_project
      return if current_project
      render status: 404, json: { error: true, message: "Invalid project specified." }
    end

    def require_deploy
      return if current_deploy
      render status: 404, json: { error: true, message: "Invalid deploy specified." }
    end

    def require_result
      return if current_result
      render status: 404, json: { error: true, message: "Invalid result specified." }
    end
  end
end
