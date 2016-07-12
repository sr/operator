module Api
  class BuildsController < Controller
    before_action :require_project, only: [:index]

    def index
      @builds = current_project.builds(
        branch: params[:branch_name],
        include_untested_builds: false,
      )
    end
  end
end
