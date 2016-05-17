class SQLQuery
  class ParseError < StandardError
  end

  ACCOUNT_TABLE = "account"
  DEFAULT_LIMIT = 10

  def self.parse(query)
    ast = SQLParser::Parser.new.scan_str(query)
    new(ast)
  rescue Racc::ParseError
    raise ParseError, $!.message
  end

  def initialize(ast)
    @ast = ast
  end

  def sql
    @ast.to_sql
  end

  def select_all?
    @ast.to_sql.starts_with?("SELECT *")
  end

  def limit(count = DEFAULT_LIMIT)
    if @ast.limit
      return self
    end

    @ast.limit = SQLParser::Statement::Limit.new(count)
    self
  end

  def scope_to(account_id)
    where = @ast.query_expression.table_expression.where_clause
    account_id = SQLParser::Statement::Integer.new(account_id)
    condition = SQLParser::Statement::Equals.new(account_id_column, account_id)

    if !where
      where = SQLParser::Statement::WhereClause.new(condition)
    else
      and_condition = SQLParser::Statement::And.new(where.search_condition, condition)
      where = SQLParser::Statement::WhereClause.new(and_condition)
    end

    @ast.query_expression.table_expression.where_clause = where
  end

  private

  def account_id_column
    if table_name == ACCOUNT_TABLE
      SQLParser::Statement::QualifiedColumn.new(
        SQLParser::Statement::Table.new(ACCOUNT_TABLE),
        SQLParser::Statement::Column.new("id")
      )
    else
      SQLParser::Statement::Column.new("account_id")
    end
  end

  # TODO(sr) Make this more robust and handle more than basic queries
  def table_name
    @ast.query_expression.
      table_expression.
      from_clause.
      tables[0].
      name
  end
end
