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
    if account? && account_specific_table(table_name(ast))
      ast.query_expression.table_expression.where_clause = restrict_to_account(ast.query_expression.table_expression.where_clause)
    end
    ast
  end

  def table_name(ast)
    # TODO - this doesn't handle joins yet
    ast.try(:query_expression).try(:table_expression).try(:from_clause).try(:tables).try(:first).try(:name)
  end

  def account_specific_table(tablename)
    return true if tablename.nil?
    connection.columns(tablename).map(&:name).include?("account_id")
  end

  def restrict_to_account(original_where)
    #TODO - this will repeat the account_id query if it's already added
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
