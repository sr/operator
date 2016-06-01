class BranchesController < ApplicationController
  before_filter :require_project

  def index
    @branches = current_project.branches
    if params[:search].present?
      @branches = @branches.find_all { |b| b.name =~ /#{params[:search]}/i }
    end

    @branches = @branches.sort_by(&:name)
  end
end
