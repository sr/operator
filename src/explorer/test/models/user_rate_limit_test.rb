require "test_helper"

class UserRateLimitTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "at_limit?" do
    limit = UserRateLimit.new(@user, 10.minutes, 5)
    assert_equal false, limit.at_limit?

    4.times do
      limit.record_transaction
    end

    assert_equal false, limit.at_limit?
    limit.record_transaction
    assert_equal true, limit.at_limit?

    assert_equal false, limit.at_limit?(20.minutes.from_now)
  end

  test "record_transaction" do
    now = Time.current
    limit = UserRateLimit.new(@user, 10.minutes, 10)

    assert_equal 10.minutes, limit.resets_in(now)
    assert_equal 0, limit.transactions_count

    limit.record_transaction(now)

    assert_equal 5.minutes.to_i, limit.resets_in((now + 5.minutes).to_i).to_i
    assert_equal 1, limit.transactions_count
  end
end
