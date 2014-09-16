class Query < ActiveRecord::Base
  belongs_to :account
  has_many :access_logs
  validates :account_id, presence: true, if: :account?

  def account?
    database == DB::Account
  end

  def select_all?
    sql.match(/SELECT \*/i)
  end

  def tables
    connection.tables
  end

  def execute(cmd)
    connection.execute(cmd)
  end

  def connection
    case database
    when DB::Account
      account.shard(datacenter).class.connection
    when DB::Global
      case datacenter
      when DC::Dallas
        GlobalD.connection
      when DC::Seattle
        GlobalS.connection
      end
    end
  end

  def parse(input)
    parser = SQLParser::Parser.new
    command = input.slice(0, input.index(';') || input.size) # Only 1 command
    
    ast = parser.scan_str(command)
    if account?
      restrict_to_account(ast) if account_specific_table(extract_table_name(ast))
      restrict_to_account(ast, "id") if extract_table_name(ast) == "account"
    end
    append_limit(ast) if is_limited
    ast
  end

  def extract_table_name(ast)
    # TODO - this doesn't handle joins yet
    ast.try(:query_expression).try(:table_expression).try(:from_clause).try(:tables).try(:first).try(:name)
  end

  private

  def account_specific_table(tablename)
    return true if tablename.nil?
    connection.columns(tablename).map(&:name).include?("account_id")
  end

  def restrict_to_account(ast, column_name = "account_id")
    original_where = ast.query_expression.table_expression.where_clause
    #TODO - this will repeat the account_id query if it's already added
    account_id_constant = SQLParser::Statement::Integer.new(account_id)
    column_reference = SQLParser::Statement::Column.new(column_name)
    account_condition = SQLParser::Statement::Equals.new(column_reference, account_id_constant)
    if original_where.nil?
      where_clause = SQLParser::Statement::WhereClause.new(account_condition)
    else
      and_condition = SQLParser::Statement::And.new(original_where.search_condition, account_condition)
      where_clause = SQLParser::Statement::WhereClause.new(and_condition)
    end
    ast.query_expression.table_expression.where_clause = where_clause
    ast
  end

  def append_limit(ast, row_count = 10)
    if ast.limit.nil?
      ast.limit = SQLParser::Statement::Limit.new(row_count)
    else
      self.is_limited = false
    end
    ast
  end
end
