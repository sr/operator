class DataCenter
  class NotFound < StandardError
    def initialize(name)
      super "datacenter not found: #{name.inspect}"
    end
  end

  DALLAS = "dallas".freeze
  SEATTLE = "seattle".freeze

  def self.default_name
    DALLAS
  end

  def initialize(user, name)
    @user = user
    @name = name

    if ![DALLAS, SEATTLE].include?(name)
      raise NotFound, name
    end
  end

  attr_reader :name

  def global
    config = config_file.global(@name)

    Database.new(@user, config)
  end

  def shard_for(account_id)
    account = find_account(account_id)
    config = config_file.shard(@name, account.shard_id)

    Database.new(@user, config)
  end

  def find_account(account_id)
    global_accounts.find(account_id)
  end

  def accounts
    global_accounts.all
  end

  private

  def global_accounts
    @global_accounts ||= GlobalAccountsCollection.new(@user, global)
  end

  def config_file
    @config ||= DatabaseConfigurationFile.load
  end
end
