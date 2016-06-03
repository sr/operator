class ChefDeliveryNotification
  def initialize(github_url, room_id, repo, master)
    @github_url = github_url
    @room_id = room
    @repo = repo
    @master = master
  end

  def deploy_started(deploy)
  end

  def deploy_completed(deploy)
  end

  private

  def compare_url(branch)
    "#{@github_url}/#{@repo}/compare/#{@master}...#{branch}"
  end

  def notify(message)
    Hipchat.notify_room(@room, message)
  end
end
