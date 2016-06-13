class UserQuery < ActiveRecord::Base
  DEFAULT_LIMIT = 10
  SUPPORT_ROLE = 9

  belongs_to :user

  class RateLimited < StandardError
    def initialize(user)
      super "user #{user.email} rate limited"
    end
  end

  class UnauthorizedAccountAccess < StandardError
    def initialize(account_id)
      @account_id = account_id

      super "access to account #{account_id.inspect} is not authorized"
    end

    attr_reader :account_id
  end

  BlankResultSet = Struct.new(:fields).new([])

  # Returns an empty result set.
  def blank
    BlankResultSet
  end

  # Returns a Mysql2::Result with the result of executing the query against the
  # appropriate database. Execution is accounted against the given user's rate
  # limit and the query is written to an audit log.
  def execute(current_user)
    if current_user.rate_limit.at_limit?
      raise UserQuery::RateLimited, current_user
    end

    data = {
      hostname: database.hostname,
      database: database.name,
      query: parsed.sql,
      user_email: current_user.email
    }
    Instrumentation.log(data)

    results = database.execute(parsed.sql)
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

    DataCenter.current.find_account(account_id).descriptive_name
  end

  def database_name
    database.name
  end

  # Returns an Array of tables present in the database.
  def database_tables
    database.tables
  end

  # Returns the parsed SQL query with the account_id condition added if this
  # is an account-specific account and with a LIMIT clause added.
  def parsed
    sql_query = SQLQuery.parse(raw_sql).limit(DEFAULT_LIMIT)

    if !for_account?
      return sql_query
    end

    sql_query.scope_to(account_id)
  end

  private

  def database
    if for_account?
      if !access_authorized?(account_id)
        raise UnauthorizedAccountAccess, account_id
      end
      DataCenter.current.shard_for(account_id)
    else
      DataCenter.current.global
    end
  end

  def access_authorized?(account_id)
    return true if user.group == User::FULL_ACCESS

    query = <<-SQL.freeze
      SELECT id FROM global_account_access
      WHERE role = ? AND account_id = ? AND (expires_at IS NULL OR expires_at > NOW())
      LIMIT 1
    SQL
    results = DataCenter.current.global.execute(query, [SUPPORT_ROLE, account_id])
    results.size == 1
  end
end
