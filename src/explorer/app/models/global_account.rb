class GlobalAccount < ApplicationRecord
  establish_connection(Datacenter.current_activerecord_config)
  self.table_name = "global_account"
  self.inheritance_column = nil

  def to_s
    "#{company} #{shard_id}/#{id}"
  end
end
