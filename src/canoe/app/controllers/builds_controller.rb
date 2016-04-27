class BuildsController < ApplicationController
  before_filter :require_repo

  def index
    @include_untested_builds = (params[:include_untested_builds] == "1")

    @builds = current_repo.builds(
      branch: params[:branch_name],
      include_untested_builds: @include_untested_builds,
    )
  end

  private
  def current_branch
    @current_branch ||= current_repo.branch(params[:branch_name])
  end
  helper_method :current_branch
end
