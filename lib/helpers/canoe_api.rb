module Canoe
  module API
    def is_api?
      request.fullpath =~ /^\/api/
    end

    def require_api_target!
      unless current_target
        halt 200, {}, { error: true, message: "Invalid target specified." }.to_json
      end
    end

    def require_api_user!
      unless current_user
        halt 200, {}, { error: true, message: "Invalid user specified." }.to_json
      end
    end

    def require_api_repo!
      unless current_repo
        halt 200, {}, { error: true, message: "Invalid repo specified." }.to_json
      end
    end

  end
end
