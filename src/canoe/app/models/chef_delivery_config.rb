class ChefDeliveryConfig
  PRODUCTION = "production"
  DEV = "dev"

  AWS = "pardot0-chef1-1-ue1.aws"
  DFW = "pardot0-chef1-1-dfw"
  PHX = "pardot0-chef1-1-phx"

  BREAD_TESTING_ROOM = 882
  OPS_ROOM = 6

  def enabled_in?(environment, hostname)
    case environment
    when DEV
      true
    when PRODUCTION
      [AWS].include?(hostname)
    else
      false
    end
  end

  def repo_name
    ENV.fetch("CANOE_CHEF_REPO", "Pardot/chef")
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

  def github_url
    Project::GITHUB_URL
  end

  def github_repo
    @github_repo ||= GithubRepository.new(
      Octokit::Client.new(
        api_endpoint: "#{github_url}/api/v3",
        access_token: github_token
      ),
      repo_name
    )
  end

  def chat_room_id(hostname)
    case hostname
    when AWS
      BREAD_TESTING_ROOM
    else
      Integer(ENV.fetch("CANOE_CHEF_CHAT_ROOM_ID", OPS_ROOM))
    end
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
    ENV.fetch("GITHUB_PASSWORD")
  end
end
