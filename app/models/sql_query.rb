class SQLQuery
  class ParseError < StandardError
  end

  DEFAULT_LIMIT = 10.freeze

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

  def limit(count = DEFAULT_LIMIT)
    if !@ast.limit
      @ast.limit = SQLParser::Statement::Limit.new(count)
    end
  end

  def scope_to(account_id)
    if account?
      restrict_to_account(ast) if account_specific_table(extract_table_name(ast))
      restrict_to_account(ast, ["account","id"]) if extract_table_name(ast) == "account"
    end
  end

  def restrict_to_account(column_name = "account_id")
    original_where = @ast.query_expression.table_expression.where_clause
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
end
