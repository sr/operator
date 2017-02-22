class SQLQuery
  ACCOUNT_TABLE = "account".freeze
  NamedTable = Struct.new(:name, :alias, :is_account?)

  def initialize(query)
    @ast = SQLParser::Parser.new.scan_str(query.sub(/;$/, ""))
  rescue Racc::ParseError, SQLParser::Parser::ScanError
    raise ArgumentError, $!.message
  end

  def to_sql
    @ast.to_sql
  end

  def select_all?
    @ast.to_sql.starts_with?("SELECT *")
  end

  def tables
    tables = @ast.query_expression.table_expression.from_clause.tables
    tables.map { |table_ast|
      table_name(table_ast)
    }.flatten
  end

  def limit(count)
    if @ast.limit
      return self
    end

    @ast.limit = SQLParser::Statement::Limit.new(count)
    self
  end

  def scope_to(user_query, account_id)
    ScopedSQLQuery.new(@ast, account_id, user_query)
  end

  private

  def table_name(ast)
    if ast.respond_to?(:name)
      NamedTable.new(ast.name, ast.name, ast.name == ACCOUNT_TABLE)
    elsif ast.respond_to?(:value) && ast.respond_to?(:column) # Named tables
      NamedTable.new(ast.value.name, ast.column.name, ast.value.name == ACCOUNT_TABLE)
    elsif ast.is_a?(SQLParser::Statement::QualifiedJoin)
      [table_name(ast.left), table_name(ast.right)]
    end
  end
end
