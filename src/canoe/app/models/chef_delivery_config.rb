class ChefDeliveryConfig
  PRODUCTION = "production".freeze
  DEV = "dev".freeze

  AWS = "ue1".freeze
  DFW = "dfw".freeze
  PHX = "phx".freeze

  ENABLED = [AWS, PHX, DFW].freeze

  BREAD_ROOM = 42
  OPS_ROOM = 6

  def enabled?(server)
    case server.environment
    when DEV
      true
    when PRODUCTION
      ENABLED.include?(server.datacenter)
    else
      false
    end
  end

  def knife_notifications_enabled?(_server)
    true
  end

  def master_branch
    "master"
  end

  def max_lock_age
    30.minutes
  end

  def github_repo
    @github_repo ||= GithubRepository.new(
      Canoe.config.github_client,
      Canoe.config.chef_repository_name
    )
  end

  def chat_room_id(server)
    case server.datacenter
    when AWS
      if server.hostname =~ /^pardot2/
        return OPS_ROOM
      end

      BREAD_ROOM
    else
      Integer(ENV.fetch("CANOE_CHEF_CHAT_ROOM_ID", OPS_ROOM))
    end
  end

  def notifier
    @notifier ||= HipchatNotifier.new
  end
end
