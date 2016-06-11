class FakeRateLimit
  def exceeded?
    true
  end

  def resets_in
    3.minutes
  end

  def period
    15.minutes
  end

  def max_queries
    10
  end
end
