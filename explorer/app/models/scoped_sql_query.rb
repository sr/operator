class ScopedSQLQuery < SQLQuery
  def initialize(ast, account_id, user_query)
    @user_query = user_query
    @ast = ast
    @account_id = account_id

    tables.each do |table|
      if !scoped?(table)
        scope!(table)
      end
    end
  end

  private

  def scopable?(table)
    table.is_account? || @user_query.database_columns(table).include?("account_id")
  end

  def scoped?(table)
    return true unless scopable?(table)

    where = @ast.query_expression.table_expression.where_clause

    if !where
      return false
    end

    if where.search_condition.is_a?(SQLParser::Statement::And)
      return where.search_condition.left.to_sql == condition(table).to_sql ||
             where.search_condition.right.to_sql == condition(table).to_sql
    end

    where.search_condition.to_sql == condition(table).to_sql
  end

  def scope!(table)
    where = @ast.query_expression.table_expression.where_clause

    if !where
      where = SQLParser::Statement::WhereClause.new(condition(table))
    else
      and_condition = SQLParser::Statement::And.new(where.search_condition, condition(table))
      where = SQLParser::Statement::WhereClause.new(and_condition)
    end

    @ast.query_expression.table_expression.where_clause = where
  end

  def condition(table)
    account_id = SQLParser::Statement::Integer.new(@account_id)
    SQLParser::Statement::Equals.new(account_id_column(table), account_id)
  end

  def account_id_column(table)
    if table.is_account?
      column_name = "id"
    else
      column_name = "account_id"
    end

    SQLParser::Statement::QualifiedColumn.new(
      SQLParser::Statement::Table.new(table.alias),
      SQLParser::Statement::Column.new(column_name)
    )
  end
end
