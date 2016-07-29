class BuildsController < ApplicationController
  before_action :require_project

  def index
    @include_untested_builds = (params[:include_untested_builds] == "1")

    @builds = current_project.builds(
      branch: params[:branch_name],
      include_untested_builds: @include_untested_builds,
    )
  end

  private

  def current_branch
    @current_branch ||= current_project.branch(params[:branch_name])
  end
  helper_method :current_branch
end
