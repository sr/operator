require "test_helper"

class GlobalSettingTest < ActiveSupport::TestCase
  test "secondary_db_id default" do
    assert_equal 2, GlobalSetting.secondary_db_id(0)
  end

  test "secondary_db_id site-switch" do
    assert_equal "prod-s", Datacenter.current.symfony_name
    GlobalSetting.transaction do
      GlobalSetting.create(setting_key: "prod-s shard3 datacenter", setting_value: GlobalSetting::SERVER_SETTING_2)
      assert_equal 1, GlobalSetting.secondary_db_id(3)
      raise ActiveRecord::Rollback
    end
  end

  test "secondary_db_id no-failover" do
    GlobalSetting.transaction do
      GlobalSetting.create(setting_key: "prod-s shard3 datacenter", setting_value: GlobalSetting::SERVER_SETTING_1_ONLY)
      assert_equal 1, GlobalSetting.secondary_db_id(3)
      raise ActiveRecord::Rollback
    end
  end
end
