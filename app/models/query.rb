class Query < ActiveRecord::Base
  self.table_name = 'pardotexplorer_queries'
  belongs_to :account
  belongs_to :user
  validates :account_id, presence: true, if: :account?

  def account?
    database == "Account"
  end

  def tables
    case database
    when "Account"
      account.shard.tables
    when "Global"
      PardotGlobalExternal.connection.tables
    end
  end

  def execute(cmd)
    case database
    when "Account"
      account.shard.class.connection.execute(cmd)
    when "Global"
      PardotGlobalExternal.connection.execute(cmd)
    end
  end
end
