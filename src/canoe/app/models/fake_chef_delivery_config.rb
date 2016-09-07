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

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
