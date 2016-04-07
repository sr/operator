class Account < GlobalDallas
  self.table_name = 'global_account'
  self.inheritance_column = :_type_disabled
  has_many :account_accesses

  def descriptive_name
    "#{company} #{shard_id}/#{id}"
  end

  def self.determine_shard(account_id)
    account = find(account_id)
    account.shard_id
  end

  def shard(datacenter = DataCenter::DALLAS)
    @_shard ||= {
        DataCenter::DALLAS => Account.create_shard(shard_id, DataCenter::DALLAS),
        DataCenter::SEATTLE => Account.create_shard(shard_id, DataCenter::SEATTLE)
      }
    @_shard[datacenter]
  end

  def access?
    if Rails.env.development?
      return true
    end

    # Role 7 is engineering
    !account_accesses.where(role: 7).where("expires_at > ?", Time.now).empty?
  end

  def self.create_shard(shard_id, datacenter = DataCenter::DALLAS)
    shard_name = "Shard#{shard_id}#{datacenter.capitalize}"
    begin
      shard_name.constantize
    rescue NameError
      klass = Class.new(PardotShardExternal) do
        self.table_name = "account"
      end
      Object.const_set shard_name, klass
      constant = shard_name.constantize
      constant.class_eval do
        establish_shard_connection(datacenter, shard_id)
      end
      constant
    end
  end
end
