class GlobalSetting < ApplicationRecord
  establish_connection(Datacenter.current_activerecord_config)
  self.table_name = "global_setting"

  # primary shard db enumeration
  SERVER_SETTING_DEFAULT = 0
  SERVER_SETTING_1 = 1
  SERVER_SETTING_2 = 2
  SERVER_SETTING_1_ONLY = 3
  SERVER_SETTING_2_ONLY = 4

  def self.secondary_db_id(shard_id)
    setting = find_by(setting_key: "#{Datacenter.current.symfony_name} shard#{shard_id} datacenter")
    db_state = Integer(setting.setting_value) if setting

    # The idea is to run Pardot Explorer on the secondary database, so the opposite of what the main
    # app runs on. The exception is if a db is put in no-failover mode, in which case Pardot Explorer
    # will run on the primary.
    case db_state
    when SERVER_SETTING_2, SERVER_SETTING_1_ONLY
      1
    when nil, SERVER_SETTING_DEFAULT, SERVER_SETTING_1, SERVER_SETTING_2_ONLY
      2
    else
      raise "Unexpected db_state value: #{db_state.inspect}"
    end
  end
end
