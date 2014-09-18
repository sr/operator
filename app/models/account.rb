class Account < GlobalD
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
        DC::Dallas => Shard.new(shard_id, DC::Dallas),
        DC::Seattle => Shard.new(shard_id, DC::Seattle)
      }
    @_shard[datacenter]
  end

  def access?
    # Role 7 is engineering
    !account_accesses.where(role: 7).where("expires_at > ?", Time.now).empty?
  end
end
