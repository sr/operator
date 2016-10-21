class Database
  GLOBAL = "global".freeze
  SHARD = "shard".freeze

  def initialize(config)
    @config = config
  end

  def hostname
    @config.hostname
  end

  def name
    @config.name
  end

  def tables
    activerecord_connection.data_sources
  end

  def columns(table)
    activerecord_connection.columns(table).map(&:name)
  end

  def execute(sql, params = [])
    Instrumentation.log(
      database: name,
      hostname: hostname,
      query: sql,
      params: params
    )
    connection.query(sql)
  end

  private

  def connection
    @connection ||= establish_connection
  end

  def activerecord_connection
    @activerecord_connection ||=
      ActiveRecord::ConnectionAdapters::Mysql2Adapter.new(
        connection,
        nil,
        nil,
        connection_config
      )
  end

  def establish_connection
    connection = Mysql2::Client.new(connection_config)
    connection.query_options[:symbolize_keys] = true
    # BREAD-1428 Since we have invalid dates already in our db, such as 0000-00-00 00:00:00
    # we're disabling casting for all queries
    connection.query_options[:cast] = false
    connection
  end

  def connection_config
    {
      host: @config.hostname,
      port: @config.port,
      username: @config.username,
      password: @config.password,
      database: @config.name
    }
  end
end
