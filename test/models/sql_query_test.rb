require "test_helper"

class SQLQueryTest < ActiveSupport::TestCase
  def parse(query)
    SQLQuery.parse(query)
  end

  test "standard query" do
    assert parse("SELECT * FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "select field query" do
    assert parse("SELECT id FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "select field query with e in front" do
    assert parse("SELECT email_ip_id FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "quoted select field query with e in front" do
    assert parse("SELECT `email_ip_id` FROM `account` WHERE `id` = 1 LIMIT 10")
  end

  test "only backticks work as quotes" do
    assert_raises(SQLQuery::ParseError) do
      parse("SELECT \"email_ip_id\" FROM `account` WHERE `id` = 1 LIMIT 10")
    end

    assert_raises(SQLQuery::ParseError) do
      parse("SELECT 'email_ip_id' FROM `account` WHERE `id` = 1 LIMIT 10")
    end
  end

  test "date" do
    sql = 'select email_id from visitor_activity where type=12 and created_at<DATE "2014-07-23"'
    assert parse(sql)
  end

  test "advanced Join" do
    sql = 'select va.email_id,e.list_email_id,e.name,va.prospect_id,p.email,va.type,va.created_at from visitor_activity va left join prospect p on p.id=va.prospect_id left join email e on e.id=va.email_id where va.type=12 and va.created_at<"2014-07-23" and va.created_at>"2014-07-22"'
    assert parse(sql)
  end

  test "function calls" do
    sql = 'select prospect_id from piListxProspect where (listx_id=1 or listx_id=2) and account_id=1 and is_mailable=1 order by rand() limit 10'
    assert parse(sql)
  end

  test "lazy text - no quotes" do
    sql = "select * from fromtable"
    assert parse(sql)
  end
end
