class Account < GlobalDallas
  self.table_name = 'global_account'
  self.inheritance_column = :_type_disabled
  has_many :queries
  has_many :account_accesses

  def descriptive_name
    "#{company} #{shard_id}/#{id}"
  end

  def self.determine_shard(account_id)
    account = find(account_id)
    account.shard_id
  end

  def shard(datacenter = DC::Dallas)
    @_shard ||= {
        DC::Dallas => Account.create_shard(shard_id, DC::Dallas),
        DC::Seattle => Account.create_shard(shard_id, DC::Seattle)
      }
    @_shard[datacenter]
  end

  def access?
    # Role 7 is engineering
    !account_accesses.where(role: 7).where("expires_at > ?", Time.now).empty?
  end

  def self.create_shard(shard_id, datacenter = DC::Dallas)
    # Dynamically creates Shard Classes which hold the db connection for us
    shard_name = "Shard#{shard_id}#{datacenter}"
    begin
      shard_name.constantize
    rescue NameError
      klass = Class.new(PardotShardExternal) do
        self.table_name = "account"
      end
      Object.const_set shard_name, klass
      shard_name.constantize.class_eval do
        establish_connection_on_shard(shard_id, datacenter)
      end
    end
  end

end
