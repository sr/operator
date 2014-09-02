class Shard < PardotShardExternal
  self.table_name = "account"
  establish_connection_on_shard(1) # Default so it can load the first time

  def initialize(shard_id)
    Shard.establish_connection_on_shard(shard_id)
  end
end
