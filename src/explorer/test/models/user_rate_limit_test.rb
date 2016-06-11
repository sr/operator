require "test_helper"

class UserRateLimitTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "exceeded?" do
    limit = UserRateLimit.new(@user, 10.minutes, 5)
    assert_equal false, limit.exceeded?

    5.times do
      limit.record_transaction
    end
    assert_equal false, limit.exceeded?

    limit.record_transaction

    assert_equal true, limit.exceeded?
    assert_equal false, limit.exceeded?(20.minutes.from_now)
  end

  test "record_transaction" do
    now = Time.current
    limit = UserRateLimit.new(@user, 10.minutes, 10)

    assert_equal 10.minutes, limit.resets_in(now)
    assert_equal 0, limit.transactions_count

    limit.record_transaction(now)

    assert_in_delta 5.minutes, limit.resets_in(now + 5.minutes)
    assert_equal 1, limit.transactions_count
  end
end
