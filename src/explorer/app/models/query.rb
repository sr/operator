class Query
  # TODO(sr) Remove these constants
  SQL = "sql".freeze
  UI = "ui".freeze

  class ExecutionRefused < StandardError
  end

  class RateLimitExceeded < StandardError
    def initialize(user)
      super "query rate limit exceeded for user #{user.email}"
    end
  end

  def initialize(database, connection, sql)
    @database = database
    @connection = connection
    @sql = sql
  end

  def execute(user, params = [])
    assert_valid(user)
    audit_log(user, params)

    statement = @connection.prepare(@sql)
    results = statement.execute(*params)
    user.rate_limit.record_transaction
    results
  end

  private

  def audit_log(user, params)
    data = {
      hostname: @database.hostname,
      database: @database.name,
      query: @sql,
      params: params,
      user_email: user.email
    }
    Instrumentation.log(data)
  end

  def assert_valid(user)
    if !user.is_a?(User)
      raise ExecutionRefused, "invalid user: #{user.inspect}"
    end

    if user.new_record?
      raise ExecutionRefused, "user not persisted: #{user.inspect}"
    end

    if !user.email.present?
      raise ExecutionRefused, "user has no email: #{user.inspect}"
    end

    if user.rate_limit.exceeded?
      raise RateLimitExceeded, user
    end
  end
end
