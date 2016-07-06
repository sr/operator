require "test_helper"

class GlobalAccountAccessTest < ActiveSupport::TestCase
  test "account not authorized by fixtures" do
    assert_not GlobalAccountAccess.authorized?(1)
  end

  test "account authorized after adding unexpiring access" do
    authorize_access(1)
    assert GlobalAccountAccess.authorized?(1)
  end

  test "account authorized after adding expiring access" do
    authorize_access(1, nil, 1.minute.ago.end_of_day.to_s(:db))
    assert GlobalAccountAccess.authorized?(1)
  end
end
