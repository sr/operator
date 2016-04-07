class Query
  CSV = "CSV"
  UI = "UI"
  SQL = "SQL"

  def initialize(attributes = {})
    @datacenter = attributes.fetch(:datacenter, DataCenter::DALLAS)
    @database = attributes.fetch(:database, Database::GLOBAL)
    @sql = attributes.fetch(:sql, "")
    @account_id = attributes.delete(:account_id)
    @view = attributes.fetch(:view, SQL)
  end

  def sql
    @sql
  end

  attr_reader :view, :datacenter, :database, :sql
  attr_accessor :account_id
  attr_writer :is_limited, :sql

  def errors
    []
  end

  def account?
    @database == Database::SHARD
  end

  def select_all?
    @sql.match(/SELECT \*/i)
  end

  def tables
    connection.tables
  end

  def is_limited
    true
  end

  def account
    if @account_id
      Account.find(@account_id)
    end
  end

  def execute(user, query)
    if !user.kind_of?(AuthUser)
      raise ArgumentError, "user must be a AuthUser"
    end

    data = {
      database: @database,
      datacenter: @datacenter,
      query: @sql,
      user_name: user.name,
      user_email: user.email,
    }
    if @account_id
      data[:account_id] = @account_id
    end
    Instrumentation.log(data)

    connection.execute(@sql)
  end

  def connection
    case @database
    when Database::SHARD
      account.shard(@datacenter).connection
    when Database::GLOBAL
      case @datacenter
      when DataCenter::DALLAS
        GlobalDallas.connection
      when DataCenter::SEATTLE
        GlobalSeattle.connection
      end
    end
  end

  def parse(input)
    parser = SQLParser::Parser.new
    command = input.slice(0, input.index(';') || input.size) # Only 1 command
    
    ast = parser.scan_str(command)
    if account?
      restrict_to_account(ast) if account_specific_table(extract_table_name(ast))
      restrict_to_account(ast, ["account","id"]) if extract_table_name(ast) == "account"
    end
    append_limit(ast) if is_limited
    ast
  end

  def extract_table_name(ast)
    # TODO - this doesn't handle joins yet
    tables = ast.try(:query_expression).try(:table_expression).try(:from_clause).try(:tables).try(:first)
    tables.try(:name) || tables.try(:left).try(:name)
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
    if column_name.is_a?(Array)
      column_table = SQLParser::Statement::Table.new(column_name[0])
      column_column = SQLParser::Statement::Column.new(column_name[1])
      column_reference = SQLParser::Statement::QualifiedColumn.new(column_table, column_column)
    else
      column_reference = SQLParser::Statement::Column.new(column_name)
    end
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
