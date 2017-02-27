class SQLParser::Parser

option
  ignorecase

macro
  DIGIT      [0-9]
  UINT       {DIGIT}+
  BLANK      \s+
  WB         \b

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

            \'            { @state = :STRS;  [:quote, text] }
  :STRS     \'            { @state = nil;    [:quote, text] }
  :STRS     .*(?=\')      {                  [:character_string_literal, text.gsub("''", "'")] }

            \"            { @state = :STRD;  [:quote, text] }
  :STRD     \"            { @state = nil;    [:quote, text] }
  :STRD     .*(?=\")      {                  [:character_string_literal, text.gsub('""', '"')] }

            {UINT}        { [:unsigned_integer, text.to_i] }

# built-in functions
            {IDENT}\(\)   { [:built_in_function, text] }

# skip
            {BLANK}       # no action

# keywords
            {WB}EXPLAIN{WB}       { [:EXPLAIN, text] }
            {WB}SELECT{WB}        { [:SELECT, text] }
            {WB}DISTINCT{WB}      { [:DISTINCT, text] }
            {WB}DATE{WB}          { [:DATE, text] }
            {WB}ASC{WB}           { [:ASC, text] }
            {WB}AS{WB}            { [:AS, text] }
            {WB}FROM{WB}          { [:FROM, text] }
            {WB}WHERE{WB}         { [:WHERE, text] }
            {WB}BETWEEN{WB}       { [:BETWEEN, text] }
            {WB}AND{WB}           { [:AND, text] }
            {WB}NOT{WB}           { [:NOT, text] }
            {WB}INNER{WB}         { [:INNER, text] }
            {WB}INSERT{WB}        { [:INSERT, text] }
            {WB}INTO{WB}          { [:INTO, text] }
            {WB}IN{WB}            { [:IN, text] }
            {WB}ORDER{WB}         { [:ORDER, text] }
            {WB}OR{WB}            { [:OR, text] }
            {WB}LIKE{WB}          { [:LIKE, text] }
            {WB}IS{WB}            { [:IS, text] }
            {WB}NULL{WB}          { [:NULL, text] }
            {WB}COUNT{WB}         { [:COUNT, text] }
            {WB}AVG{WB}           { [:AVG, text] }
            {WB}MAX{WB}           { [:MAX, text] }
            {WB}MIN{WB}           { [:MIN, text] }
            {WB}SUM{WB}           { [:SUM, text] }
            {WB}GROUP{WB}         { [:GROUP, text] }
            {WB}BY{WB}            { [:BY, text] }
            {WB}HAVING{WB}        { [:HAVING, text] }
            {WB}CROSS{WB}         { [:CROSS, text] }
            {WB}JOIN{WB}          { [:JOIN, text] }
            {WB}ON{WB}            { [:ON, text] }
            {WB}LEFT{WB}          { [:LEFT, text] }
            {WB}OUTER{WB}         { [:OUTER, text] }
            {WB}RIGHT{WB}         { [:RIGHT, text] }
            {WB}FULL{WB}          { [:FULL, text] }
            {WB}USING{WB}         { [:USING, text] }
            {WB}EXISTS{WB}        { [:EXISTS, text] }
            {WB}DESC{WB}          { [:DESC, text] }
            {WB}CURRENT_USER{WB}  { [:CURRENT_USER, text] }
            {WB}VALUES{WB}        { [:VALUES, text] }
            {WB}LIMIT{WB}         { [:LIMIT, text] }
            {WB}OFFSET{WB}        { [:OFFSET, text] }
            {WB}FALSE{WB}         { [:FALSE, text] }
            {WB}TRUE{WB}          { [:TRUE, text] }

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
