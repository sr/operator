require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  setup do 
    @gquery = Query.new(
      database: DB::Global,
      datacenter: DC::Dallas,
    )
    @aquery = Query.new(
      database: DB::Account,
      datacenter: DC::Dallas,
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

  def extract_table_name_test(expected, command)
    ast = SQLParser::Parser.new.scan_str(command)
    @query = Query.new
    assert_equal expected, @query.extract_table_name(ast)
  end

  # Do different selects
  test "standard query" do
    assert SQLParser::Parser.new.scan_str("SELECT * FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "select field query" do
    assert SQLParser::Parser.new.scan_str("SELECT id FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "select field query with e in front" do
    assert_raises(ParseError) { SQLParser::Parser.new.scan_str("SELECT email_ip_id FROM `account` WHERE `id` = 1 LIMIT 10") }
  end

  test "quoted select field query with e in front" do
    assert SQLParser::Parser.new.scan_str("SELECT `email_ip_id` FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "only backticks work as quotes" do
    assert_raises(ParseError) { SQLParser::Parser.new.scan_str("SELECT \"email_ip_id\" FROM `account` WHERE `id` = 1 LIMIT 10") }
    assert_raises(ParseError) { SQLParser::Parser.new.scan_str("SELECT 'email_ip_id' FROM `account` WHERE `id` = 1 LIMIT 10") }
  end

  # Parse tests
  test "Should not add account restrictions to global db" do
    sql = "SELECT * FROM `account`"
    assert_equal "#{sql} #{@limit}", @gquery.parse(sql).to_sql
  end

  test "Should not replace LIMIT already given" do
    sql = "SELECT * FROM `account` LIMIT 20"
    assert_equal sql, @gquery.parse(sql).to_sql
  end

  test "Should add account restrictions to account db" do
    sql = "SELECT * FROM `account`"
    assert_equal "#{sql} WHERE `account`.`id` = #{@aquery.account_id} #{@limit}", @aquery.parse(sql).to_sql
  end

  test "Should add account restrictions to account db if they have account_id column" do
    sql = "SELECT * FROM `bitly_url`"
    assert_equal "#{sql} WHERE `account_id` = #{@aquery.account_id} #{@limit}", @aquery.parse(sql).to_sql
  end

  test "Should only add account restrictions if account_id column exists" do
    sql = "SELECT * FROM `deleted_object`"
    assert_equal "#{sql} #{@limit}", @aquery.parse(sql).to_sql
  end
end
