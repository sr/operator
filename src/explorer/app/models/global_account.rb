class GlobalAccount < ActiveRecord::Base
  establish_connection(
    adapter:  "mysql2",
    host:     Datacenter.current_global_config.hostname,
    username: Datacenter.current_global_config.username,
    password: Datacenter.current_global_config.password,
    database: Datacenter.current_global_config.name
  )
  self.table_name = "global_account"
  self.inheritance_column = nil

  def to_s
    "#{company} #{shard_id}/#{id}"
  end
end
