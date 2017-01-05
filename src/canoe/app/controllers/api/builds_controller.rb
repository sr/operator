module Api
  class BuildsController < Controller
    before_action :require_project, only: [:index]

    def index
      @builds = current_project.builds(branch: params[:branch_name])
        .slice(
          (current_page - 1) * pagination_page_size,
          pagination_page_size
        )
    end

    private

    def pagination_page_size
      5
    end
  end
end
