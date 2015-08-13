class TargetsController < ApplicationController
  before_filter :require_target

  def show
    @total_deploys = current_target.deploys.count
    @deploys = current_target.deploys
      .order(created_at: :desc)
      .limit(pagination_page_size)
      .offset(pagination_page_size * (current_page - 1))
  end

  def lock
    lock_target!
    redirect_to target_path(current_target)
  end

  def unlock
    unlock_target!(force: (params[:force] == "1"))
    redirect_to target_path(current_target)
  end
end
