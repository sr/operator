class DataCenter
  class NotFound < StandardError
    def initialize(name)
      super "datacenter not found: #{name.inspect}"
    end
  end

  DALLAS = "dfw".freeze
  LOCAL = "local".freeze
  SEATTLE = "phx".freeze

  # Returns the current Datacenter based on the Rails configuration.
  def self.current
    @datacenter ||= DataCenter.new(
      Rails.application.config.x.datacenter,
      DatabaseConfigurationFile.load
    )
  end

  def initialize(name, config)
    @name = name
    @config = config

    if ![DALLAS, LOCAL, SEATTLE].include?(name)
      raise NotFound, name
    end
  end

  attr_reader :name

  def global
    config = @config.global(@name)

    Database.new(config)
  end

  def shard_for(account_id)
    account = find_account(account_id)
    config = @config.shard(@name, account.shard_id)

    Database.new(config)
  end

  def find_account(account_id)
    global_accounts.find(account_id)
  end

  def accounts
    global_accounts.all
  end

  private

  def global_accounts
    @global_accounts ||= GlobalAccountsCollection.new(global)
  end
end
