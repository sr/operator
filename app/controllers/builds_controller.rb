class BuildsController < ApplicationController
  before_filter :require_repo

  def index
    @include_untested_builds = (params[:include_untested_builds] == "1")

    @branch = current_repo.branch(params[:branch_name])
    @builds = current_repo.builds(
      branch: @branch.name,
      include_untested_builds: @include_untested_builds,
    )
  end
end
