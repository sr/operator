require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  setup do 
    @user = AuthUser.new(
      email: "user@salesforce.com",
      name: "user",
    )
    @gquery = Query.new(
      database: Database::GLOBAL,
      datacenter: DataCenter::DALLAS,
    )
    @aquery = Query.new(
      database: Database::SHARD,
      datacenter: DataCenter::DALLAS,
      account_id: 1,
    )
    @limit = "LIMIT 10"
  end

  # Extract_table_name
  test "simple lookup" do
    extract_table_name_test("account", "SELECT * FROM `account`")
  end

  test "join" do
    extract_table_name_test("account", "SELECT * FROM `account` INNER JOIN `account_access` ON `account`.`id` = `account_access`.`account_id`")
  end

  test "left join" do
    extract_table_name_test("account", "SELECT * FROM `account` LEFT JOIN `account_access` ON `account`.`id` = `account_access`.`account_id`")
  end

  def extract_table_name_test(expected, sql)
    ast = SQLQuery.parse(sql)
    @query = Query.new
    assert_equal expected, @query.extract_table_name(ast)
  end

  test "execute" do
    assert_raises(ArgumentError) do
      @gquery.execute(nil, "SELECT 1")
    end
    @gquery.sql = "SELECT 1"
    result = @gquery.execute(@user, "SELECT 1")
    assert_equal "1", result.fields[0]

    log = Instrumentation::Logging.entries[0]
    assert_equal DataCenter::DALLAS, log[:datacenter]
    assert_equal Database::GLOBAL, log[:database]
    assert_equal "SELECT 1", log[:query]
    assert_equal "user@salesforce.com", log[:user_email]
    assert_equal "user", log[:user_name]
  end

  test "does not add account restrictions to global db" do
    sql = "SELECT * FROM `account`"
    assert_equal "#{sql} #{@limit}", @gquery.parse(sql).to_sql
  end

  test "does not replace LIMIT already given" do
    sql = "SELECT * FROM `account` LIMIT 20"
    assert_equal sql, @gquery.parse(sql).to_sql
  end

  test "adds account restrictions to account db" do
    sql = "SELECT * FROM `account`"
    assert_equal "#{sql} WHERE `account`.`id` = #{@aquery.account_id} #{@limit}", @aquery.parse(sql).to_sql
  end

  test "adds account restrictions to account db if they have account_id column" do
    sql = "SELECT * FROM `bitly_url`"
    assert_equal "#{sql} WHERE `account_id` = #{@aquery.account_id} #{@limit}", @aquery.parse(sql).to_sql
  end

  test "only adds account restrictions when account_id column exists" do
    sql = "SELECT * FROM `deleted_object`"
    assert_equal "#{sql} #{@limit}", @aquery.parse(sql).to_sql
  end
end
