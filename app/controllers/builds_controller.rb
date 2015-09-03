class BuildsController < ApplicationController
  before_filter :require_repo

  def index
    @branch = current_repo.branch(params[:branch_name])
    @builds = current_repo.builds(branch: @branch.name)
  end
end
