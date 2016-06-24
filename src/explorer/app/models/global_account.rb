class GlobalAccount < ActiveRecord::Base
  establish_connection(
    adapter:  "mysql2",
    host:     Datacenter.current.global_config.hostname,
    username: Datacenter.current.global_config.username,
    password: Datacenter.current.global_config.password,
    database: Datacenter.current.global_config.name
  )
  self.table_name = "global_account"
  self.inheritance_column = "rails_type"

  def to_s
    "#{company} #{shard_id}/#{id}"
  end
end
