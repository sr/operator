require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  setup do
    @account = Account.find(1)
  end

  test "test account access" do
    # Solaris Panels should have access
    assert @account.access?
  end

  test "EC Software should not have access" do
    assert_not Account.find(2).access?
  end

  test "Dynamically create shard" do
    assert Account.create_shard(1)
  end
end
