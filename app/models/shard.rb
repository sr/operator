class Shard < PardotShardExternal
  self.table_name = "account"
  establish_connection_on_shard(1, "Dallas") # Default so it can load the first time

  def initialize(shard_id, datacenter = Dallas)
    Shard.establish_connection_on_shard(shard_id, datacenter)
  end
end
