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

  def initialize(database, connection, user, sql)
    @database = database
    @connection = connection
    @user = user
    @sql = sql
  end

  def execute(params = [])
    assert_valid
    audit_log(params)

    if @user.rate_limit_exceeded?
      raise RateLimitExceeded, @user
    end

    statement = @connection.prepare(@sql)
    statement.execute(*params)
  end

  private

  def audit_log(params)
    data = {
      hostname: @database.hostname,
      database: @database.name,
      query: @sql,
      params: params,
      user_email: @user.email
    }
    Instrumentation.log(data)
  end

  def assert_valid
    if !@user.is_a?(User)
      raise ExecutionRefused, "invalid user: #{@user.inspect}"
    end

    if @user.new_record?
      raise ExecutionRefused, "user not persisted: #{@user.inspect}"
    end

    if !@user.email.present?
      raise ExecutionRefused, "user has no email: #{@user.inspect}"
    end
  end
end
