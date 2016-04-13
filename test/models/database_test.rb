require "test_helper"

class DatabaseTest < ActiveSupport::TestCase
  setup do
    @user = AuthUser.create!(name: "boom town", email: "sr@sfdc.be")
    @datacenter = @user.datacenter
  end

  test "name" do
    authorize_access(@datacenter, 1)
    assert_equal "pardot_shard1", @datacenter.shard_for(1).name
  end

  test "tables" do
    tables = @datacenter.global.tables
    assert tables.include?("global_account")
    assert_equal 42, tables.size
  end

  test "execute" do
    authorize_access(@datacenter, 2)
    database = @datacenter.shard_for(2)
    results = database.execute("SELECT * FROM object_audit")
    row = results.first
    assert_equal 1, row[:id]
    assert_equal 1, row[:account_id]
    assert_equal "Account", row[:object_type]

    results = database.execute("SELECT * FROM object_audit WHERE id = ?", 1)
    row = results.first
    assert_equal 1, row[:id]
  end

  test "execute with invalid query" do
    assert_raise(Query::ExecutionRefused) do
      user = AuthUser.new
      user.datacenter.global.execute("SELECT * FROM job")
    end

    assert_raise(Query::ExecutionRefused) do
      user = AuthUser.new(email: "sr@sfdc.be")
      user.datacenter.global.execute("SELECT * FROM job")
    end

    database = @datacenter.global
    query = Query.new(database, nil, nil, "SELECT 1")
    assert_raise(Query::ExecutionRefused) do
      query.execute
    end
  end

  test "audit log" do
    database = @datacenter.global
    database.execute("SELECT 1")
    assert log = Instrumentation::Logging.entries.pop
    assert_equal "mysql", log[:hostname]
    assert_equal "pardot_global", log[:database]
    assert_equal "SELECT 1", log[:query]
    assert_equal @user.email, log[:user_email]
    assert_equal [], log[:params]

    authorize_access(@datacenter, 1)
    database = @datacenter.shard_for(1)
    assert log = Instrumentation::Logging.entries.pop
    assert_equal [1], log[:params]

    database.execute("SELECT 1")
    assert log = Instrumentation::Logging.entries.pop
    assert_equal "SELECT 1", log[:query]
  end
end
