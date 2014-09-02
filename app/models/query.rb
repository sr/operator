class Query < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  validates :account_id, presence: true, if: :account?

  # Database
  Account = "Account"
  Global = "Global"

  # View
  SQL = "SQL"
  UI = "UI"

  # Datacenter
  Dallas = "Dallas"
  Seattle = "Seattle"

  def account?
    database == Account
  end

  def tables
    connection.tables
  end

  def execute(cmd)
    connection.execute(cmd)
  end

  def connection
    case database
    when Account
      account.shard.class.connection
    when Global
      PardotGlobalExternal.connection
    end
  end

  def parse(input)
    parser = SQLParser::Parser.new
    command = input.slice(0, input.index(';') || input.size) # Only 1 command
    
    ast = parser.scan_str(command)
    my_columns = connection.columns(ast.query_expression.table_expression.from_clause.tables.first.name)
    ast.query_expression.table_expression.where_clause = restrict_to_account(ast.query_expression.table_expression.where_clause) if account? && my_columns.map(&:name).include?("account_id")
    ast
  end

  def restrict_to_account(original_where)
    account_id_constant = SQLParser::Statement::Integer.new(account_id)
    column_reference = SQLParser::Statement::Column.new('account_id')
    account_condition = SQLParser::Statement::Equals.new(column_reference, account_id_constant)
    if (original_where.nil?)
      where_clause = SQLParser::Statement::WhereClause.new(account_condition)
    else
      and_condition = SQLParser::Statement::And.new(original_where.search_condition, account_condition)
      where_clause = SQLParser::Statement::WhereClause.new(and_condition)
    end
  end
end
