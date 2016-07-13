module ReplicationFixing
  class ReplicationErrorSanitizer
    def initialize
    end

    def sanitize(error)
      error.gsub(/Query: '(.+)'/) do
        sanitized_query = Regexp.last_match(1).gsub(/'((?:[^'\\]|\\.)*?)'/) do
          quoted_string = $&.to_s

          potential_string = Regexp.last_match(1).to_s
          if potential_string.empty? || potential_string =~ /^([\s\d\.:-]+|[0-9a-zA-Z]{15}|[0-9a-zA-Z]{18})$/
            # This string is blank or just a number or identifier. These aren't considered PII.
            quoted_string
          else
            "[REDACTED]"
          end
        end

        "Query: '#{sanitized_query}'"
      end
    end
  end
end
