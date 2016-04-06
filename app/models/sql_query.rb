class SQLQuery
  class ParseError < StandardError
  end

  def self.parse(query)
    SQLParser::Parser.new.scan_str(query)
  rescue Racc::ParseError
    raise ParseError, $!.message
  end
end
