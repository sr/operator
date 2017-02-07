class DeployTarget < ApplicationRecord
  # validations, uniqueness, etc
  has_many :deploys
  has_many :locks
  belongs_to :locking_user, class_name: AuthUser

  scope :enabled, -> { where(enabled: true) }

  def to_param
    name
  end

  def last_deploy_for(project_name)
    deploys
      .where(project_name: project_name)
      .order(id: :desc)
      .first
  end

  def last_successful_deploy_for(project_name)
    deploys
      .where(
        project_name: project_name,
        completed: true,
        canceled:  false
      )
      .order(id: :desc)
      .first
  end

  def previous_deploy(deploy)
    deploys
      .where(project_name: deploy.project_name)
      .where("id < ?", deploy.id)
      .order(id: :desc)
      .first
  end

  def previous_successful_deploy(deploy)
    deploys
      .where(
        project_name: deploy.project_name,
        completed: true,
        canceled:  false
      )
      .where("id < ?", deploy.id)
      .order(id: :desc)
      .first
  end

  def active_deploy(project)
    if latest_deploy = most_recent_deploy(project)
      latest_deploy unless latest_deploy.completed?
    end
  end

  def most_recent_deploy(project)
    deploys
      .where(project_name: project.name)
      .order(id: :desc)
      .first
  end

  def lock!(project, user)
    locks.find_or_create_by!(project: project, auth_user: user)
  end

  def unlock!(project, _user)
    locks.where(project: project).destroy_all
  end

  # Finds an existing lock on the target and project
  def existing_lock(project)
    locks.where(project: project).first
  end

  def user_can_deploy?(project, user)
    lock = existing_lock(project)
    lock.nil? || lock.auth_user == user
  end

  def servers(project:)
    Server
      .enabled
      .active
      .joins(:deploy_scenarios)
      .where(deploy_scenarios: { deploy_target_id: id, project_id: project.id })
  end
end
