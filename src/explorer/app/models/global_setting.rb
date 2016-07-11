class GlobalSetting < ActiveRecord::Base
  establish_connection(
    adapter:  "mysql2",
    host:     Datacenter.current_global_config.hostname,
    username: Datacenter.current_global_config.username,
    password: Datacenter.current_global_config.password,
    database: Datacenter.current_global_config.name
  )
  self.table_name = "global_setting"

  def self.secondary_db_id(shard_id)
    setting = find_by_setting_key("#{Datacenter.current.symfony_name} shard#{shard_id} datacenter")
    db_state = Integer(setting.setting_value) if setting
    # setting_value enumeration
    # SERVER_SETTING_DEFAULT = 0;
    # SERVER_SETTING_1 = 1;
    # SERVER_SETTING_2 = 2;
    # SERVER_SETTING_1_ONLY = 3;
    # SERVER_SETTING_2_ONLY = 4;

    # The idea is to run Pardot Explorer on the secondary database, so the opposite of what the main
    # app runs on. The exception is if a db is put in no-failover mode, in which case Pardot Explorer
    # will run on the primary.
    case db_state
    when nil, 0, 1, 4
      2
    when 2, 3
      1
    end
  end
end
