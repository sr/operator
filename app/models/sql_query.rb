class SQLQuery
  class ParseError < StandardError
  end

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
    if !@ast.limit
      @ast.limit = SQLParser::Statement::Limit.new(count)
    end
  end

  def scope_to(account_id)
    where = @ast.query_expression.table_expression.where_clause
    account_id = SQLParser::Statement::Integer.new(account_id)
    column = SQLParser::Statement::Column.new("account_id")
    condition = SQLParser::Statement::Equals.new(column, account_id)
    if !where
      where = SQLParser::Statement::WhereClause.new(condition)
    else
      and_condition = SQLParser::Statement::And.new(where.search_condition, condition)
      where = SQLParser::Statement::WhereClause.new(and_condition)
    end
    @ast.query_expression.table_expression.where_clause = where
  end
end
