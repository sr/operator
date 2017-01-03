class BuildsController < ApplicationController
  before_action :require_project

  def index
    @builds = current_project.builds(
      branch: params[:branch_name]
    )
  end

  private

  def current_branch
    @current_branch ||= current_project.branch(params[:branch_name])
  end
  helper_method :current_branch
end
