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

  def shard_for(account_id)
    account = find_account(account_id)
    config = @config.shard(@name, account.shard_id)

    Database.new(config)
  end

  def find_account(account_id)
    begin
      id = Integer(account_id)
    rescue TypeError
      raise ArgumentError, "invalid account id: #{id.inspect}"
    end

    sql_query = "#{default_accounts_query} WHERE id = ? LIMIT 1"
    results = global.execute(sql_query, [id])

    if results.count.zero?
      raise StandardError, "global_account id=#{id.inspect} not found"
    end

    GlobalAccount.new(results.first)
  end

  def accounts
    global.execute("#{default_accounts_query} LIMIT 100").map do |result|
      GlobalAccount.new(result)
    end
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

  private

  def global_accounts
    @global_accounts ||= GlobalAccountsCollection.new(global)
  end

  def default_accounts_query
    "SELECT id, shard_id, company FROM global_account"
  end
end
