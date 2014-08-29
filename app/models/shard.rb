class Shard < PardotShardExternal
  self.table_name = "account"

  def initialize(shard_id)
    Shard.establish_connection_on_shard(shard_id)
  end
  
  def tables
    Shard.connection.tables
  end
end
