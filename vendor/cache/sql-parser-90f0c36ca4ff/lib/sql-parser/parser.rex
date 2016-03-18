class SQLParser::Parser

option
  ignorecase

macro
  DIGIT   [0-9]
  UINT    {DIGIT}+
  BLANK   \s+

  YEARS   {UINT}
  MONTHS  {UINT}
  DAYS    {UINT}
  DATE    {YEARS}-{MONTHS}-{DAYS}

  IDENT   \w+

rule
# [:state]  pattern       [actions]

# literals
            \"{DATE}\"    { [:date_string, Date.parse(text)] }
            \'{DATE}\'    { [:date_string, Date.parse(text)] }

            \'            { state = :STRS;  [:quote, text] }
  :STRS     \'            { state = nil;    [:quote, text] }
  :STRS     .*(?=\')      {                 [:character_string_literal, text.gsub("''", "'")] }

            \"            { state = :STRD;  [:quote, text] }
  :STRD     \"            { state = nil;    [:quote, text] }
  :STRD     .*(?=\")      {                 [:character_string_literal, text.gsub('""', '"')] }

            {UINT}        { [:unsigned_integer, text.to_i] }

# built-in functions
            {IDENT}\(\)   { [:built_in_function, text] }

# skip
            {BLANK}       # no action

# keywords
            SELECT\s      { [:SELECT, text] }
            DATE\s        { [:DATE, text] }
            ASC\s         { [:ASC, text] }
            AS\s          { [:AS, text] }
            FROM\s        { [:FROM, text] }
            WHERE\s       { [:WHERE, text] }
            BETWEEN\s     { [:BETWEEN, text] }
            AND\s         { [:AND, text] }
            NOT\s         { [:NOT, text] }
            INNER\s       { [:INNER, text] }
            INSERT\s      { [:INSERT, text] }
            INTO\s        { [:INTO, text] }
            IN\s          { [:IN, text] }
            ORDER\s       { [:ORDER, text] }
            OR\s          { [:OR, text] }
            LIKE\s        { [:LIKE, text] }
            IS\s          { [:IS, text] }
            NULL\s        { [:NULL, text] }
            COUNT\s       { [:COUNT, text] }
            AVG\s         { [:AVG, text] }
            MAX\s         { [:MAX, text] }
            MIN\s         { [:MIN, text] }
            SUM\s         { [:SUM, text] }
            GROUP\s       { [:GROUP, text] }
            BY\s          { [:BY, text] }
            HAVING\s      { [:HAVING, text] }
            CROSS\s       { [:CROSS, text] }
            JOIN\s        { [:JOIN, text] }
            ON\s          { [:ON, text] }
            LEFT\s        { [:LEFT, text] }
            OUTER\s       { [:OUTER, text] }
            RIGHT\s       { [:RIGHT, text] }
            FULL\s        { [:FULL, text] }
            USING\s       { [:USING, text] }
            EXISTS\s      { [:EXISTS, text] }
            DESC\s        { [:DESC, text] }
            CURRENT_USER\s{ [:CURRENT_USER, text] }
            VALUES\s      { [:VALUES, text] }
            LIMIT\s       { [:LIMIT, text] }
            OFFSET\s      { [:OFFSET, text] }

# tokens
            <>            { [:not_equals_operator, text] }
            !=            { [:not_equals_operator, text] }
            =             { [:equals_operator, text] }
            <=            { [:less_than_or_equals_operator, text] }
            <             { [:less_than_operator, text] }
            >=            { [:greater_than_or_equals_operator, text] }
            >             { [:greater_than_operator, text] }

            \(            { [:left_paren, text] }
            \)            { [:right_paren, text] }
            \*            { [:asterisk, text] }
            \/            { [:solidus, text] }
            \+            { [:plus_sign, text] }
            \-            { [:minus_sign, text] }
            \.            { [:period, text] }
            ,             { [:comma, text] }

# identifier
            `{IDENT}`     { [:identifier, text[1..-2]] }
            {IDENT}       { [:identifier, text] }

---- header ----
require 'date'
