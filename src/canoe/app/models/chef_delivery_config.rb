class ChefDeliveryConfig
  def enabled_in?(environment)
    %w[dev].include?(environment)
  end

  def repo_name
    ENV["CANOE_CHEF_REPO"] || "Pardot/chef"
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
    @github_repo ||= GithubRepository.new(
      Octokit::Client.new(login: "simon-rozet", password: github_token),
      repo_name
    )
  end

  def chat_room_id
    ENV["CANOE_CHEF_CHAT_ROOM_ID"] || 6 # Ops
  end

  class HipchatNotifier
    def self.notify_room(room_id, message, color = nil)
      Hipchat.notify_room(room_id, message, false, color)
    end
  end

  def notifier
    @notifier ||= HipchatNotifier
  end

  private

  def github_token
    ENV["CANOE_CHEF_GITHUB_TOKEN"]
  end

  def chat_token
    "TODO"
  end
end
