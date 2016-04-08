class Query
  class ExecutionRefused < StandardError
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
      user_email: @user.email,
    }
    Instrumentation.log(data)
  end

  def assert_valid
    if !@user.is_a?(AuthUser)
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
