class SQLQuery
  class ParseError < StandardError
  end

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
