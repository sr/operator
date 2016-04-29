class ReposController < ApplicationController
  before_filter :require_target, only: [:lock, :unlock]
  before_filter :require_repo, only: [:show, :lock, :unlock]

  def index
    @repos = all_repos
  end

  def show
  end

  def lock
    current_target.lock!(current_repo, current_user)
    redirect_to target_url(current_target), notice: "Lock acquired"
  rescue
    redirect_to target_url(current_target), alert: "Unable to acquire a lock: a lock already exists"
  end

  def unlock
    current_target.unlock!(current_repo, current_user)
    redirect_to target_url(current_target), notice: "Lock released"
  rescue
    redirect_to target_url(current_target), alert: "Unable to unlock: a lock already exists"
  end
end
