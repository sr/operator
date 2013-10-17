module Canoe
  module Guards
    def guard_against_unknown_repos!
      if !current_repo
        flash[:notice] = "Requested repo is unknown."
        redirect back
      end
    end

    def guard_against_unknown_targets!
      if !current_target
        flash[:notice] = "Requested target is unknown."
        redirect back
      end
    end
  end
end