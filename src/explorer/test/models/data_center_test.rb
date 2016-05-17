require "test_helper"

class DataCenterTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @datacenter = @user.datacenter
  end

  test "shard_for" do
    authorize_access(@datacenter, 2)
    database = @datacenter.shard_for(2)
    assert_equal "pardot_shard1", database.name

    assert_raise(DataCenter::UnauthorizedAccountAccess) do
      @datacenter.shard_for(1)
    end

    authorize_access(@datacenter, 1, 6)
    assert_raise(DataCenter::UnauthorizedAccountAccess) do
      @datacenter.shard_for(1)
    end
  end

  test "find_account" do
    account = @datacenter.find_account(1)
    assert_equal "Solaris Panels", account.company

    assert_raise(ArgumentError) do
      @datacenter.find_account(nil)
    end

    assert_raise(GlobalAccountsCollection::NotFound) do
      @datacenter.find_account(99)
    end
  end

  test "accounts" do
    accounts = @datacenter.accounts
    assert_equal 2, accounts.size

    account = accounts[1]
    assert_equal "Eastern Cloud Software 2/2", account.descriptive_name
  end
end
