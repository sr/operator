class BuildsController < ApplicationController
  before_filter :require_repo

  def index
    @include_failed_builds = (params[:include_failed_builds] == "1")

    @branch = current_repo.branch(params[:branch_name])
    @builds = current_repo.builds(
      branch: @branch.name,
      include_failed_builds: @include_failed_builds,
    )
  end
end
