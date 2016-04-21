class DatabaseConfiguration
  Auth = Struct.new(:username, :password)

  def initialize(config, auth)
    @hostname = config.fetch("host")
    @name = config.fetch("database")
    @port = config.fetch("port", 3306)
    @auth = auth
  end

  attr_reader :hostname, :name, :port

  def username
    @auth.username
  end

  def password
    @auth.password
  end
end
