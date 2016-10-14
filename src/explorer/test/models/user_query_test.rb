require "test_helper"

class UserQueryTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "execute" do
    query = @user.account_query("SELECT * FROM object_audit", 1)
    results = query.execute(@user)
    row = results.first
    assert_equal 1, row[:id]
    assert_equal 1, row[:account_id]
    assert_equal "Account", row[:object_type]

    query = @user.global_query("SELECT * FROM global_account WHERE id = 1")
    results = query.execute(@user)
    row = results.first
    assert_equal 1, row[:id]
  end

  test "global query audit log" do
    query = @user.global_query("SELECT 1 FROM global_account")
    reset_logger
    query.execute(@user)
    assert log = Instrumentation::Logging.entries.pop
    assert log.key?(:hostname), "audit log has no hostname key"
    assert_equal "pardot_global", log[:database]
    assert_equal "SELECT 1 FROM `global_account` LIMIT 10", log[:query]
    assert_equal @user.email, log[:user_email]
  end

  test "account query audit log" do
    query = @user.account_query("SELECT 1 FROM account", 1)
    query.execute(@user)
    assert Instrumentation::Logging.entries.pop
  end

  test "global tables" do
    query = @user.global_query("SELECT 1 FROM job")
    tables = query.database_tables
    assert_includes tables, "global_account"
    assert_equal 42, tables.size
  end

  test "account tables" do
    query = @user.account_query("SELECT 1 FROM job", 2)
    tables = query.database_tables
    assert_includes tables, "campaign_source_stats"
    assert_equal 347, tables.size
  end

  test "rate limiting" do
    begin
      old_val = Rails.application.config.x.rate_limit_max = 2

      @user.global_query("SELECT 1").execute(@user)
      @user.global_query("SELECT 1").execute(@user)

      assert_raises(UserQuery::RateLimited) do
        @user.global_query("SELECT 1").execute(@user)
      end
    ensure
      Rails.application.config.x.rate_limit_max = old_val
    end
  end

  test "tables without account_id" do
    query = @user.account_query("SELECT * FROM visitor_parameter", 1)
    results = query.execute(@user)
    row = results.first
    assert_equal 1, row[:id]
  end

  test "trying to get access to data from other account id" do
    query = @user.account_query("SELECT * FROM account LEFT JOIN visitor_parameter ON visitor_parameter.created_at <> account.created_at WHERE account.id = 3", 1)
    results = query.execute(@user)
    assert_nil results.first
  end

  test "trying to get access to data from other account id using table without account_id" do
    query = @user.account_query("SELECT * FROM visitor_parameter LEFT JOIN account ON visitor_parameter.created_at <> account.created_at WHERE account.id = 3", 1)
    results = query.execute(@user)
    assert_nil results.first
  end

  test "other account data using ||" do
    query = @user.account_query("select account_id, last_name, first_name, updated_at, is_archived from prospect where is_archived=1 OR is_archived=0", 1)
    results = query.execute(@user)
    row = results.first
    assert_equal 1, row[:account_id]
  end

  test "bad datetime data in table" do
    query = @user.account_query("select * from account_extras", 1)
    results = query.execute(@user)
    row = results.first
    assert_equal 1, row[:account_id]
  end
end
