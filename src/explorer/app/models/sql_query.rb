class SQLQuery
  def initialize(query)
    @ast = SQLParser::Parser.new.scan_str(query)
  rescue Racc::ParseError, SQLParser::Parser::ScanError
    raise ArgumentError, $!.message
  end

  def to_sql
    @ast.to_sql
  end

  def select_all?
    @ast.to_sql.starts_with?("SELECT *")
  end

  def limit(count)
    if @ast.limit
      return self
    end

    @ast.limit = SQLParser::Statement::Limit.new(count)
    self
  end

  def scope_to(account_id)
    @ast = ScopedSQLQuery.new(@ast, account_id).ast
    self
  end
end
