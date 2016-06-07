class FakeChefDeliveryNotifier
  def initialize
    @messages = []
  end

  attr_reader :messages

  def at_lock_age_limit(checkout)
    @messages << "boom"
  end
end
