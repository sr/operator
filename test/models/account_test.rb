require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "test account access" do
    # Solaris Panels should have access
    assert Account.find(1).access?
  end

  test "EC Software should not have access" do
    assert_not Account.find(2).access?
  end
end
