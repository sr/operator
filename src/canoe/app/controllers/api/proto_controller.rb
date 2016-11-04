module Api
  class ProtoController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_oauth_authentication
    before_action :require_api_authentication
    before_action :require_email_authentication

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

    def require_phone_authentication
      if !current_user || !current_user.authenticate_phone(action: phone_auth_action)
        render status: 401, json: { error: true, message: "Phone authentication required" }
        return false
      end

      true
    end

    def current_user
      @proto_current_user ||= AuthUser.find_by_email(proto_request.user_email)
    end

    def phone_auth_action
      raise NotImplementedError, "phone_auth_action"
    end

    def proto_request
      raise NotImplementedError, "proto_request"
    end
  end
end
