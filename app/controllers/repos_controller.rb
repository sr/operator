class ReposController < ApplicationController
  before_filter :require_repo

  def show
    @repo = current_repo
  end
end
