class ScopedSQLQuery
  ACCOUNT_TABLE = "account".freeze

  def initialize(ast, account_id)
    @ast = ast
    @account_id = account_id
  end

  def ast
    if !scoped?
      scope!
    end

    @ast
  end

  private

  def scoped?
    where = @ast.query_expression.table_expression.where_clause

    if !where
      return false
    end

    if where.search_condition.is_a?(SQLParser::Statement::And)
      return where.search_condition.left.to_sql == condition.to_sql ||
             where.search_condition.right.to_sql == condition.to_sql
    end

    where.search_condition.to_sql == condition.to_sql
  end

  def scope!
    where = @ast.query_expression.table_expression.where_clause

    if !where
      where = SQLParser::Statement::WhereClause.new(condition)
    else
      and_condition = SQLParser::Statement::And.new(where.search_condition, condition)
      where = SQLParser::Statement::WhereClause.new(and_condition)
    end

    @ast.query_expression.table_expression.where_clause = where
  end

  def condition
    account_id = SQLParser::Statement::Integer.new(@account_id)
    SQLParser::Statement::Equals.new(account_id_column, account_id)
  end

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
    @ast.query_expression
        .table_expression
        .from_clause
        .tables[0]
        .name
  end
end
