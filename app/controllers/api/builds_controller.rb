class Api::BuildsController < Api::Controller
  before_filter :require_repo, only: [:index]

  def index
    @builds = current_repo.builds(
      branch: params[:branch_name],
      include_untested_builds: false,
    )
  end
end
