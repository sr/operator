class BuildsController < ApplicationController
  before_action :require_project

  def index
    @allow_pending_builds = (params[:allow_pending_builds] == "1")

    @builds = current_project.builds(
      branch: params[:branch_name],
      include_pending_builds: @allow_pending_builds
    )
    @total_builds = @builds.length

    @builds = @builds.slice(
      (current_page - 1) * pagination_page_size,
      pagination_page_size
    )
  end

  private

  def pagination_page_size
    5
  end

  def current_branch
    @current_branch ||= current_project.branch(params[:branch_name])
  end
  helper_method :current_branch
end
