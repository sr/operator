class ChefDeliveryNotification
  def initialize(notifier, github_url, repo_name, room_id)
    @notifier = notifier
    @github_url = github_url
    @repo = repo_name
    @room = room_id
    @room_id = room_id
  end

  def at_lock_age_limit(checkout)
    @notifier.notify_room(@room_id, "boom")
  end

  def deploy_started(deploy)
  end

  def deploy_completed(deploy)
  end

  private

  def compare_url(branch)
    return "TODO"
    # TODO(sr) "#{@github_url}/#{@repo}/compare/#{@master}...#{branch}"
  end
end
