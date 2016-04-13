require "test_helper"

class AuthUserTest < ActiveSupport::TestCase
  setup do
    @user = AuthUser.create!(uid: SecureRandom.hex, token: SecureRandom.hex,
      name: "boom", email: "sr@sfdc.be")
  end

  # TODO(sr) test "find_or_create_by_omniauth"

  test "datacenter" do
    default = @user.datacenter
    assert_equal DataCenter::DALLAS, default.name

    assert_raise(DataCenter::NotFound) do
      @user.datacenter("brussels")
    end
  end
end
