class FakeChefDeliveryConfig < ChefDeliveryConfig
  def initialize(repo)
    @github_repo = repo
  end

  attr_reader :github_repo

  def enabled_in?(environment, hostname)
    %w[testing].include?(environment) && hostname != "disabled"
  end

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
