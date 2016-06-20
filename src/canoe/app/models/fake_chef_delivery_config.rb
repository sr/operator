class FakeChefDeliveryConfig < ChefDeliveryConfig
  def initialize(repo)
    @github_repo = repo
  end

  attr_reader :github_repo

  def enabled?(server)
    server.datacenter == "test" &&
      server.environment != "disabled" &&
      server.hostname != "disabled"
  end

  class FakeHipchatNotifier
    def initialize
      @messages = []
    end

    attr_reader :messages

    Message = Struct.new(:room_id, :message)

    def notify_room(room_id, message, _color = nil)
      @messages << Message.new(room_id, message)
    end
  end

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
