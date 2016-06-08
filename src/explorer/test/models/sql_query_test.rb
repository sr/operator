require "test_helper"

class SQLQueryTest < ActiveSupport::TestCase
  def parse(query)
    SQLQuery.parse(query)
  end

  test "limit" do
    query = parse("SELECT * FROM global_agency")
    query.limit(3)
    assert_equal "SELECT * FROM `global_agency` LIMIT 3", query.sql
    query.limit(10)
    assert_equal "SELECT * FROM `global_agency` LIMIT 3", query.sql
    query = parse("SELECT * FROM global_agency LIMIT 1").limit(5)
    assert_equal "SELECT * FROM `global_agency` LIMIT 1", query.sql
  end

  test "select_all?" do
    assert !parse("SELECT id FROM table").select_all?
    assert parse("SELECT * FROM table").select_all?
  end

  test "scope_to" do
    query = parse("SELECT id FROM audit_log")
    query.scope_to(5)
    assert_equal "SELECT `id` FROM `audit_log` WHERE `account_id` = 5",
      query.sql

    query = parse("SELECT * FROM account")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE `account`.`id` = 42", query.sql

    query = parse("SELECT * FROM `account` WHERE `boom`.`id` = 42")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE (`boom`.`id` = 42 AND `account`.`id` = 42)", query.sql

    query = parse("SELECT * FROM `account` WHERE `account`.`id` = 42")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE `account`.`id` = 42", query.sql

    query = parse("SELECT * FROM `account` WHERE `account`.`id` = 42 AND `boom` = 1")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE (`account`.`id` = 42 AND `boom` = 1)", query.sql
  end

  test "only backticks work as quotes" do
    assert_raises(SQLQuery::ParseError) do
      parse("SELECT \"email_ip_id\" FROM `account` WHERE `id` = 1 LIMIT 10")
    end

    assert_raises(SQLQuery::ParseError) do
      parse("SELECT 'email_ip_id' FROM `account` WHERE `id` = 1 LIMIT 10")
    end
  end
end