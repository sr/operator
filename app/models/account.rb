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

  def shard(datacenter = Dallas)
    @_shard ||= {
        Dallas => Shard.new(shard_id, Dallas),
        Seattle => Shard.new(shard_id, Seattle)
      }
    @_shard[datacenter]
  end
end
