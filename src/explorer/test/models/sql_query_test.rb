require "test_helper"

class SQLQueryTest < ActiveSupport::TestCase
  def parse(query)
    SQLQuery.new(query)
  end

  test "limit" do
    query = parse("SELECT * FROM global_agency")
    query.limit(3)
    assert_equal "SELECT * FROM `global_agency` LIMIT 3", query.to_sql
    query.limit(10)
    assert_equal "SELECT * FROM `global_agency` LIMIT 3", query.to_sql
    query = parse("SELECT * FROM global_agency LIMIT 1").limit(5)
    assert_equal "SELECT * FROM `global_agency` LIMIT 1", query.to_sql
  end

  test "string" do
    assert parse("SELECT * FROM global_agency WHERE `global_agency`.`name` = 'ACEDS'")
    assert parse("SELECT * FROM `global_setting` WHERE `global_setting`.`setting_key` = 'shard43' LIMIT 10")
  end

  test "select_all?" do
    assert !parse("SELECT id FROM table").select_all?
    assert parse("SELECT * FROM table").select_all?
  end

  test "scope_to" do
    query = parse("SELECT id FROM audit_log")
    query.scope_to(5)
    assert_equal "SELECT `id` FROM `audit_log` WHERE `account_id` = 5",
      query.to_sql

    query = parse("SELECT * FROM account")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE `account`.`id` = 42", query.to_sql

    query = parse("SELECT * FROM `account` WHERE `boom`.`id` = 42")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE (`boom`.`id` = 42 AND `account`.`id` = 42)", query.to_sql

    query = parse("SELECT * FROM `account` WHERE `account`.`id` = 42")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE `account`.`id` = 42", query.to_sql

    query = parse("SELECT * FROM `account` WHERE `account`.`id` = 42 AND `boom` = 1")
    query.scope_to(42)
    assert_equal "SELECT * FROM `account` WHERE (`account`.`id` = 42 AND `boom` = 1)", query.to_sql
  end

  test "Lazy text - no quotes" do
    input = "select * from fromtable"
    expect = "SELECT * FROM `fromtable`"
    assert_equal expect, parse(input).to_sql
  end

  test "table.column format" do
    input = "SELECT `user`.`first_name`, `user`.`last_name`, `user`.`email`, `user`.`created_at` from `user` where `user`.`account_id` = 1 order by `user`.`created_at` desc limit 10"
    expect = "SELECT `user`.`first_name`, `user`.`last_name`, `user`.`email`, `user`.`created_at` FROM `user` WHERE `user`.`account_id` = 1 ORDER BY `user`.`created_at` DESC LIMIT 10"
    assert_equal expect, parse(input).to_sql
  end

  # Advanced tests
  test "Date test" do
    input = 'select email_id from visitor_activity where type=12 and created_at<DATE "2014-07-23"'
    expect = "SELECT `email_id` FROM `visitor_activity` WHERE (`type` = 12 AND `created_at` < DATE '2014-07-23')"
    assert_equal expect, parse(input).to_sql
  end

  test "Advanced Join" do
    input = 'select va.email_id,e.list_email_id,e.name,va.prospect_id,p.email,va.type,va.created_at from visitor_activity va left join prospect p on p.id=va.prospect_id left join email e on e.id=va.email_id where va.type=12 and va.created_at<"2014-07-23" and va.created_at>"2014-07-22"'
    expect = "SELECT `va`.`email_id`, `e`.`list_email_id`, `e`.`name`, `va`.`prospect_id`, `p`.`email`, `va`.`type`, `va`.`created_at` FROM `visitor_activity` AS `va` LEFT JOIN `prospect` AS `p` ON `p`.`id` = `va`.`prospect_id` LEFT JOIN `email` AS `e` ON `e`.`id` = `va`.`email_id` WHERE ((`va`.`type` = 12 AND `va`.`created_at` < DATE '2014-07-23') AND `va`.`created_at` > DATE '2014-07-22')"
    assert_equal expect, parse(input).to_sql
  end

  test "Function calls" do
    input = "select prospect_id from piListxProspect where (listx_id=1 or listx_id=2) and account_id=1 and is_mailable=1 order by rand() limit 10"
    expect = "SELECT `prospect_id` FROM `piListxProspect` WHERE (((`listx_id` = 1 OR `listx_id` = 2) AND `account_id` = 1) AND `is_mailable` = 1) ORDER BY rand() ASC LIMIT 10"
    assert_equal expect, parse(input).to_sql
  end

  # Test first_table

  test "Parse table name" do
    input = "select prospect_id from piListxProspect where (listx_id=1 or listx_id=2) and account_id=1 and is_mailable=1 order by rand() limit 10"
    assert_equal "piListxProspect", parse(input).first_table
  end

  test "Parse table from join" do
    input = 'select va.email_id,e.list_email_id,e.name,va.prospect_id,p.email,va.type,va.created_at from visitor_activity va left join prospect p on p.id=va.prospect_id left join email e on e.id=va.email_id where va.type=12 and va.created_at<"2014-07-23" and va.created_at>"2014-07-22"'
    assert_equal "visitor_activity", parse(input).first_table
  end

  test "Parse table from inner join" do
    input = 'select va.email_id,e.list_email_id,e.name,va.prospect_id,p.email,va.type,va.created_at from visitor_activity va INNER join prospect p on p.id=va.prospect_id left join email e on e.id=va.email_id where va.type=12 and va.created_at<"2014-07-23" and va.created_at>"2014-07-22"'
    assert_equal "visitor_activity", parse(input).first_table
  end
end
