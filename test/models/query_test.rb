require 'test_helper'

class QueryTest < ActiveSupport::TestCase
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
end
