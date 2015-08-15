module TargetsHelper
  def last_repo_deploys(repo)
    current_target.deploys.where(repo_name: repo).order(created_at: :desc).first
  end
end
