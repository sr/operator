module Canoe
  module Authentication
    def page_requires_authentication?
      # pages that do not require authentication are login, /auth/ and the complete paths
      paths_without_auth = ["/login"]

      ( !paths_without_auth.include?(request.path_info) && \
        !request.path_info.match(%r{^/auth/}) && \
        !request.path_info.match(%r{^/api})
       )
    end

    def authentication_required!
      return unless page_requires_authentication?
      redirect "/login" unless current_user
    end

    def require_api_authentication!
      # check for proper api_auth param
      if ENV["API_AUTH_TOKEN"].nil? || params[:api_token] != ENV["API_AUTH_TOKEN"]
        halt 200, { error: true, message: "Invalid auth token" }.to_json
      end
    end

  end
end
