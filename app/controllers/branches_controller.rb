class BranchesController < ApplicationController
  before_filter :require_repo

  def index
    @branches = current_repo.branches
    if params[:search].present?
      @branches = @branches.find_all { |b| b.name =~ /#{params[:search]}/i }
    end

    render "repos/show"
  end
end
