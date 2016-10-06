class SQLQuery
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
    }
  end

  def table_name(ast)
    levels = 0
    begin
      levels += 1
      ast.name
    rescue NoMethodError
      ast = ast.left
      ast = ast.left.value if ast.respond_to?(:left)
      retry unless levels > 3
      raise NoMethodError, $!.message
    end
  end

  def limit(count)
    if @ast.limit
      return self
    end

    @ast.limit = SQLParser::Statement::Limit.new(count)
    self
  end

  def scope_to(account_id)
    ScopedSQLQuery.new(@ast, account_id)
  end
end
