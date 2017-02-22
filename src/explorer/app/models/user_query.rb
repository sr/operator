class UserQuery < ApplicationRecord
  DEFAULT_LIMIT = 10

  belongs_to :user

  class RateLimited < StandardError
    def initialize(user)
      super "user #{user.email} rate limited"
    end
  end

  BlankResultSet = Struct.new(:fields).new([])
  BlankSQLQuery = Struct.new(:to_sql, :select_all?).new("", false)

  # Returns an empty result set.
  def blank
    BlankResultSet
  end

  # Returns a Mysql2::Result with the result of executing the query against the
  # appropriate database. Execution is accounted against the given user's rate
  # limit and the query is written to an audit log.
  def execute(current_user, show_all_rows = false)
    if current_user.rate_limit.at_limit?
      raise UserQuery::RateLimited, current_user
    end

    results = Instrumentation.context(user_email: current_user.email) do
      database.execute(parse(show_all_rows).to_sql)
    end
    current_user.rate_limit.record_transaction
    results
  end

  # Returns true if this query is scoped to an account, false otherwise.
  def for_account?
    account_id.present?
  end

  # Returns the String name of the account this query is for.
  def account_name
    if !for_account?
      raise "query is not scoped to an account"
    end

    GlobalAccount.find(account_id).to_s
  end

  # Returns an Array of tables present in the database.
  def database_tables
    database.tables
  end

  def database_columns(tables = parsed)
    if tables.is_a? SQLQuery
      tables = tables.tables
    else
      tables = [tables]
    end

    tables.map { |t| database.columns(t.name) }.flatten
  end

  def parsed
    @parsed || BlankSQLQuery
  end

  private

  # Returns the parsed SQL query with the account_id condition added if this
  # is an account-specific account and with a LIMIT clause added.
  def parse(show_all_rows)
    sql_query = SQLQuery.new(raw_sql)

    if !sql_query.explain?
      if !show_all_rows
        sql_query = sql_query.limit(DEFAULT_LIMIT)
      end

      if for_account?
        sql_query = sql_query.scope_to(self, account_id)
      end
    end

    @parsed = sql_query
  end

  def database
    if for_account?
      Datacenter.current.shard_for(account_id)
    else
      Datacenter.current.global
    end
  end
end
