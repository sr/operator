class DataCenter
  class NotFound < StandardError
    def initialize(name)
      super "datacenter not found: #{name.inspect}"
    end
  end

  DALLAS = "dallas".freeze
  SEATTLE = "seattle".freeze

  def self.default
    new(DALLAS)
  end

  def self.find(name)
    case name
    when DALLAS
      new(DALLAS)
    when SEATTLE
      new(SEATTLE)
    else
      raise NotFound, name
    end
  end

  def initialize(name)
    @name = name
  end

  attr_reader :name

  def global
    config.global(@name)
  end

  def shard(account_id)
    config.shard(@name, find_account(account_id).shard_id)
  end

  def find_account(account_id)
    global_accounts.find(account_id)
  end

  private

  def global_accounts
    @global_accounts ||= GlobalAccountsCollection.new(global)
  end

  def config
    @config ||= DatabaseConfiguration.load
  end
end
