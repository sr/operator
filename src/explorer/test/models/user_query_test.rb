require "test_helper"

class UserQueryTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "database_name" do
    authorize_access(@user.datacenter, 1)
    query = @user.queries.new(raw_sql: "SELECT 1")
    assert_equal "pardot_global", query.database_name

    query = @user.queries.new(raw_sql: "SELECT 1", account_id: 1)
    assert_equal "pardot_shard1", query.database_name
  end

  test "execute_csv" do
    query = @user.global_query("SELECT * FROM global_account")
    csv = query.execute_csv
    assert csv.starts_with?("id,sfdc_org_id,sfdc_connector_username")
  end

  test "execute" do
    authorize_access(@user.datacenter, 1)
    query = @user.account_query("SELECT * FROM object_audit", 1)
    results = query.execute
    row = results.first
    assert_equal 1, row[:id]
    assert_equal 1, row[:account_id]
    assert_equal "Account", row[:object_type]

    query = @user.global_query("SELECT * FROM global_account WHERE id = 1")
    results = query.execute
    row = results.first
    assert_equal 1, row[:id]
  end

  test "execute unauthorized access" do
    query = @user.account_query("SELECT * FROM job", 1)
    assert_raise(DataCenter::UnauthorizedAccountAccess) do
      query.execute
    end
  end

  test "execute unexpiring access" do
    authorize_access(@user.datacenter, 1)
    query = @user.account_query("SELECT * FROM object_audit", 1)
    results = query.execute
    row = results.first
    assert_equal 1, row[:id]
  end

  test "execute access expiring tomorrow" do
    authorize_access(@user.datacenter, 1, nil, 'NOW() + INTERVAL 1 DAY')
    query = @user.account_query("SELECT * FROM object_audit", 1)
    results = query.execute
    row = results.first
    assert_equal 1, row[:id]
  end

  test "global query audit log" do
    query = @user.global_query("SELECT 1 FROM global_account")
    query.execute
    assert log = Instrumentation::Logging.entries.pop
    assert_equal "mysql", log[:hostname]
    assert_equal "pardot_global", log[:database]
    assert_equal "SELECT 1 FROM `global_account` LIMIT 10", log[:query]
    assert_equal @user.email, log[:user_email]
    assert_equal [], log[:params]
  end

  test "account query audit log" do
    authorize_access(@user.datacenter, 1)
    query = @user.account_query("SELECT 1 FROM account", 1)
    query.execute
    assert Instrumentation::Logging.entries.pop
  end

  test "global tables" do
    query = @user.global_query("SELECT 1 FROM job")
    tables = query.database_tables
    assert tables.include?("global_account")
    assert_equal 42, tables.size
  end

  test "account tables" do
    authorize_access(@user.datacenter, 2)
    query = @user.account_query("SELECT 1 FROM job", 2)
    tables = query.database_tables
    assert tables.include?("campaign_source_stats")
    assert_equal 347, tables.size
  end
end
