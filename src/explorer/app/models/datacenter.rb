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

  def self.current_global_config
    current.__send__(:global_config)
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

  private

  def global_config
    @config.global(@name)
  end
end
