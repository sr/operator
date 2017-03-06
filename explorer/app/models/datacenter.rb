class Datacenter
  class NotFound < StandardError
    def initialize(name)
      super "datacenter not found: #{name.inspect}"
    end
  end

  DALLAS = "dfw".freeze
  LOCAL = "local".freeze
  PHOENIX = "phx".freeze

  # Returns the current Datacenter based on the Rails configuration.
  def self.current
    @datacenter ||= Datacenter.new(
      Rails.application.config.x.datacenter,
      DatabaseConfigurationFile.load
    )
  end

  # Returns a connection Hash for connecting to the global database using
  # ActiveRecord's establish_connection method
  def self.current_activerecord_config
    {
      adapter:  "mysql2",
      host: current.global_config.hostname,
      port: current.global_config.port,
      username: current.global_config.username,
      password: current.global_config.password,
      database: current.global_config.name
    }
  end

  def initialize(name, config)
    @name = name
    @config = config

    if ![DALLAS, LOCAL, PHOENIX].include?(name)
      raise NotFound, name
    end
  end

  def symfony_name
    case name
    when DALLAS
      "prod-s"
    when PHOENIX
      "prod"
    else
      "prod-s"
    end
  end

  attr_reader :name

  def global
    config = @config.global(@name)

    Database.new(config)
  end

  def shard_for(account_id)
    account = GlobalAccount.find(account_id)
    config = @config.shard(@name, account.shard_id)

    Database.new(config)
  end

  def global_config
    @config.global(@name)
  end
end
