class ProjectsController < ApplicationController
  before_action :require_target, only: [:lock, :unlock]
  before_action :require_project, only: [:show, :lock, :unlock]
  skip_before_action :require_oauth_authentication, only: :boomtown

  def index
    @projects = all_projects
  end

  def lock
    current_target.lock!(current_project, current_user)
    redirect_to target_url(current_target), notice: "Lock acquired"
  rescue
    redirect_to target_url(current_target), alert: "Unable to acquire a lock: a lock already exists"
  end

  def unlock
    current_target.unlock!(current_project, current_user)
    redirect_to target_url(current_target), notice: "Lock released"
  rescue
    redirect_to target_url(current_target), alert: "Unable to unlock: a lock already exists"
  end

  def boomtown
    raise "boomtown"
  end
end
