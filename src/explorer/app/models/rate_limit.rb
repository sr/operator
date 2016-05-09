class RateLimit
  def initialize(user)
    @user = user
  end

  def max
    10
  end

  def exceeded?
  end

  def query_count
    Integer(@user.query_count)
  end

  def reset
    @user.update_attributes!(
      last_query_at: nil,
      query_count: nil
    )
  end
end
