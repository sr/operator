module Canoe
  module Authentication
    def page_requires_authentication?
      # pages that do not require authentication are login, /auth/ and the complete paths
      paths_without_auth = ["/login"]

      ( !paths_without_auth.include?(request.path_info) && \
        !request.path_info.match(%r{^/auth/}) && \
        !request.path_info.match(/deploy\/.*\/complete/) )
    end

    def authentication_required!
      return unless page_requires_authentication?
      redirect "/login" unless current_user
    end
  end
end
