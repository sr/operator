class Database
  GLOBAL = "global".freeze
  SHARD = "shard".freeze

  class ExecutionError < StandardError
  end

  def initialize(config)
    @hostname = config.fetch("host")
    @username = config.fetch("username")
    @password = config.fetch("password")
    @name = config.fetch("database")
    @port = config.fetch("port", 3306)
  end

  attr_reader :name

  def tables
    activerecord_connection.tables
  end

  def execute(user, query, values=[])
    if !auth_user.is_a?(AuthUser)
      raise ExecutionError, "invalid user: #{user.inspect}"
    end

    if !auth_user.email.present?
      raise ExecutionError, "user has not email: #{user.inspect}"
    end

    if query.respond_to?(:sql)
      q = query.sql
    else
      q = query
    end
    statement = connection.prepare(q)
    result = statement.execute(*values)
  end

  private

  def activerecord_connection
    @activerecord_connection ||=
      ActiveRecord::ConnectionAdapters::Mysql2Adapter.new(
        connection,
        nil,
        nil,
        {}
      )
  end

  def connection
    @connection ||= Mysql2::Client.new(
      host: @hostname,
      port: @port,
      username: @username,
      password: @password,
      database: @name,
    ).tap { |c| c.query_options.merge!(:symbolize_keys => true) }
  end
end
