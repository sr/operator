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

  def initialize(name, config)
    @name = name
    @config = config

    if ![DALLAS, LOCAL, PHOENIX].include?(name)
      raise NotFound, name
    end
  end

  attr_reader :name

  def global
    config = @config.global(@name)

    Database.new(config)
  end

  def global_config
    @config.global(@name)
  end

  def shard_for(account_id)
    account = GlobalAccount.find(account_id)
    config = @config.shard(@name, account.shard_id)

    Database.new(config)
  end

  def account_access_enabled?(account_id)
    query = <<-SQL.freeze
      SELECT id FROM global_account_access
      WHERE role = ? AND account_id = ? AND (expires_at IS NULL OR expires_at > NOW())
      LIMIT 1
    SQL

    results = global.execute(query, [Rails.application.config.x.support_role, account_id])
    results.size == 1
  end
end
