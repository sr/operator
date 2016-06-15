class FakeChefDeliveryConfig < ChefDeliveryConfig
  def initialize(repo)
    @github_repo = repo
  end

  attr_reader :github_repo

  def enabled_in?(environment, hostname)
    %w[testing].include?(environment) && hostname != "disabled"
  end

  class FakeHipchatNotifier
    def initialize
      @messages = []
    end

    attr_reader :messages

    Message = Struct.new(:room_id, :message)

    def notify_room(room_id, message, color = nil)
      @messages << Message.new(room_id, message)
    end
  end

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
