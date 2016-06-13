class UserRateLimit
  def initialize(user, period, max)
    @user = user
    @period = Integer(period)
    @max = Integer(max)
  end

  attr_reader :max, :period

  def at_limit?(now = nil)
    now ||= Time.current

    if @user.rate_limit_expires_at.nil?
      return false
    end

    if now >= @user.rate_limit_expires_at
      return false
    end

    @user.rate_limit_transactions_count >= @max
  end

  def record_transaction(now = nil)
    now ||= Time.current

    if @user.rate_limit_expires_at.nil? || now >= @user.rate_limit_expires_at
      @user.rate_limit_expires_at = now + @period
      @user.rate_limit_transactions_count = 0
    end

    @user.increment(:rate_limit_transactions_count)
    @user.save!
  end

  def resets_in(now = nil)
    now ||= Time.current

    if @user.rate_limit_expires_at.nil?
      return @period
    end

    @user.rate_limit_expires_at - now
  end

  def transactions_count
    Integer(@user.rate_limit_transactions_count)
  end
end
