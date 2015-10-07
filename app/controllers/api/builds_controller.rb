class Api::BuildsController < Api::Controller
  before_filter :require_repo, only: [:index]

  def index
    limit = params[:limit] ? params[:limit].to_i : nil

    @builds = current_repo.builds(
      branch: params[:branch_name],
      include_untested_builds: false,
      limit: limit,
    )
  end
end
