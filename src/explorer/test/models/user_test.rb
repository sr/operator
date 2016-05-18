require "test_helper"

class AuthUserTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  # TODO(sr) test "find_or_create_by_omniauth"

  test "global_accounts" do
    accounts = @user.global_accounts
    assert_equal 2, accounts.size

    account = accounts[1]
    assert_equal "Eastern Cloud Software 2/2", account.descriptive_name
  end

  test "datacenter" do
    default = @user.datacenter
    assert_equal DataCenter::DALLAS, default.name
  end
end
