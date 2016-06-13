class ExecutableUserQuery
  class Error < StandardError
  end

  DEFAULT_LIMIT = 10

  def initialize(user, query)
    @user = user
    @query = query
  end

  # Returns true if this query is scoped to an account, false otherwise.
  def for_account?
    account_id.present?
  end

  def account_id
    @query.account_id
  end

  BlankResultSet = Struct.new(:fields).new([])

  # Returns an empty result set.
  def blank
    BlankResultSet
  end

  def account_name
    if !for_account?
      raise Error, "query is not scoped to an account"
    end

    datacenter.find_account(account_id).descriptive_name
  end

  def execute
    if @user.rate_limit.at_limit?
      raise UserQuery::RateLimited, @user
    end

    audit_log

    results = database.execute(parsed.sql)
    @user.rate_limit.record_transaction
    results
  end

  def parsed
    sql_query = SQLQuery.parse(@query.raw_sql).limit(DEFAULT_LIMIT)

    if !for_account?
      return sql_query
    end

    sql_query.scope_to(account_id)
  end

  # Returns an Array of tables present in the database.
  def database_tables
    database.tables
  end

  def database_name
    database.name
  end

  private

  def database
    if for_account?
      DataCenter.current.shard_for(account_id)
    else
      DataCenter.current.global
    end
  end

  def audit_log
    data = {
      hostname: database.hostname,
      database: database.name,
      query: parsed.sql,
      user_email: @user.email
    }
    Instrumentation.log(data)
  end
end
