class DataCenter
  class NotFound < StandardError
    def initialize(name)
      super "datacenter not found: #{name.inspect}"
    end
  end

  class UnauthorizedAccountAccess < StandardError
    def initialize(account_id)
      @account_id = account_id

      super "access to account #{account_id.inspect} is not authorized"
    end

    attr_reader :account_id
  end

  ENGINEERING_ROLE = 7.freeze
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
    if !access_authorized?(account_id)
      raise UnauthorizedAccountAccess, account_id
    end

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

  def access_authorized?(account_id)
    query = <<-SQL.freeze
      SELECT id FROM global_account_access
      WHERE role = ? AND account_id = ? AND expires_at > NOW()
      LIMIT 1
    SQL
    results = global.execute(query, [ENGINEERING_ROLE, account_id])
    results.size == 1
  end

  def global_accounts
    @global_accounts ||= GlobalAccountsCollection.new(@user, global)
  end

  def config_file
    @config ||= DatabaseConfigurationFile.load
  end
end
