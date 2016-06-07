class ChefDeliveryConfig
  def enabled_in?(environment)
    false
  end

  def enabled_in?(environment)
    %w[phx].include?(environment)
  end

  def repo_name
    "Pardot/chef"
  end

  def deploy_task_name
    "knife pd sync"
  end

  def master_branch
    "master"
  end

  def max_lock_age
    1.hour
  end

  def required_successful_contexts
    ["Style and Lint Checks"]
  end

  def github_repo
    GithubRepository.new(
      Octokit::Client.new(access_token: github_token),
      repo_name
    )
  end

  def notifier
    ChefDeliveryNotification.new(
      chat_token,
      chat_room_id,
      repo_name,
      master_branch,
    )
  end

  private

  def github_token
    "TODO"
  end

  def chat_token
    "TODO"
  end

  def chat_room_id
    6 # Ops
  end
end
