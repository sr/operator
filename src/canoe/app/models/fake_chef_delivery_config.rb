class FakeChefDeliveryConfig < ChefDeliveryConfig
  def initialize(repo)
    @github_repo = repo
  end

  attr_reader :github_repo

  def enabled_in?(environment)
    %w[testing].include?(environment)
  end

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
