require "test_helper"

class AuthUserTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  # TODO(sr) test "find_or_create_by_omniauth"

  test "datacenter" do
    default = @user.datacenter
    assert_equal DataCenter::DALLAS, default.name
  end
end
