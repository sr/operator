class FakeChefDeliveryConfig < ChefDeliveryConfig
  def enabled?(server)
    server.datacenter == "test" &&
      server.environment != "disabled" &&
      server.hostname != "disabled"
  end

  def notifier
    @notifier ||= FakeHipchatNotifier.new
  end
end
