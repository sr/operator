class CommitsController < ApplicationController
  before_filter :require_repo

  def index
    @commits = current_repo.commits
    render "repos/show"
  end
end
