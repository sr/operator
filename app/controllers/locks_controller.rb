class LocksController < ApplicationController
  before_filter :require_target

  def index
    @total_locks = current_target.locks.count
    @locks = current_target.locks
      .order(created_at: :desc)
      .limit(pagination_page_size)
      .offset(pagination_page_size * (current_page - 1))

    # REFACTOR: Render "locks/index" instead, pulling out the common elements
    # from "targets/show" into partials -@alindeman
    render template: "targets/show"
  end
end
