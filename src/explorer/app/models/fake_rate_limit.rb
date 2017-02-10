class FakeRateLimit
  def at_limit?
    true
  end

  def record_transaction; end

  def resets_in
    3.minutes
  end

  def period
    15.minutes
  end

  def max
    10
  end
end
