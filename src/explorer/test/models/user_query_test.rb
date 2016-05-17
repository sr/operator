require "test_helper"

class UserQueryTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    authorize_access(@user.datacenter, 1)
  end

  test "database_name" do
    query = @user.queries.new(raw_sql: "SELECT 1")
    assert_equal "pardot_global", query.database_name

    query = @user.queries.new(raw_sql: "SELECT 1", account_id: 1)
    assert_equal "pardot_shard1", query.database_name
  end
end
