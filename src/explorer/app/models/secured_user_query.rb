class SecuredUserQuery
  class Error < StandardError
  end

  DEFAULT_LIMIT = 10

  def initialize(user, query)
    @user = user
    @query = query
  end

  def account_id
    @query.account_id
  end

  # Returns true if this query is scoped to an account, false otherwise.
  def for_account?
    account_id.present?
  end

  ResultSet = Struct.new(:fields)

  # Returns an empty result set.
  def blank
    ResultSet.new([])
  end

  def account_name
    if !for_account?
      raise Error, "query is not scoped to an account"
    end

    datacenter.find_account(account_id).descriptive_name
  end

  def execute
    database.execute(executable_query.sql)
  end

  def executable_query
    sql_query = SQLQuery.parse(@query.raw_sql).limit(DEFAULT_LIMIT)

    if !for_account?
      return sql_query
    end

    sql_query.scope_to(account_id)
  end

  def database_tables
    database.tables
  end

  def database_name
    database.name
  end

  private

  def database
    if for_account?
      datacenter.shard_for(account_id)
    else
      datacenter.global
    end
  end

  def datacenter
    DataCenter.new(
      @user,
      Rails.application.config.x.datacenter,
      DatabaseConfigurationFile.load
    )
  end
end
