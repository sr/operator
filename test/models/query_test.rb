require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  setup do 
    @gquery = Query.new(
      database: DB::Global,
      datacenter: DataCenter::DALLAS,
    )
    @aquery = Query.new(
      database: DB::Account,
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
    assert SQLParser::Parser.new.scan_str("SELECT email_ip_id FROM `account` WHERE `id` = 1 LIMIT 10")
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

  test "Lazy text - no quotes" do
    sql = "select * from fromtable"
    assert SQLParser::Parser.new.scan_str(sql)
  end

  # Advanced tests
  test "Date test" do
    sql = 'select email_id from visitor_activity where type=12 and created_at<DATE "2014-07-23"'
    assert SQLParser::Parser.new.scan_str(sql)
  end

  test "Advanced Join" do
    sql = 'select va.email_id,e.list_email_id,e.name,va.prospect_id,p.email,va.type,va.created_at from visitor_activity va left join prospect p on p.id=va.prospect_id left join email e on e.id=va.email_id where va.type=12 and va.created_at<"2014-07-23" and va.created_at>"2014-07-22"'
    assert SQLParser::Parser.new.scan_str(sql)
  end

  test "Function calls" do
    sql = 'select prospect_id from piListxProspect where (listx_id=1 or listx_id=2) and account_id=1 and is_mailable=1 order by rand() limit 10'
    assert SQLParser::Parser.new.scan_str(sql)
  end

end
