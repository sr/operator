class DatabaseConfiguration
  def initialize(config)
    @hostname = config.fetch("host")
    @username = config.fetch("username")
    @password = config.fetch("password")
    @name = config.fetch("database")
    @port = config.fetch("port", 3306)
  end

  attr_reader :hostname, :username, :password, :name, :port
end
