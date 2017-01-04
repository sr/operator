class BuildsController < ApplicationController
  before_action :require_project

  def index
    @allow_failed_builds = (params[:allow_failed_builds] == "1")

    @builds = current_project.builds(branch: params[:branch_name])
    @total_builds = @builds.length

    @builds = @builds.slice(
      (current_page - 1) * pagination_page_size,
      pagination_page_size
    )
  end

  private

  def current_branch
    @current_branch ||= current_project.branch(params[:branch_name])
  end
  helper_method :current_branch
end
