require "test_helper"

class DatabaseConfigurationTest < ActiveSupport::TestCase
  setup do
    @config = DatabaseConfiguration.load
  end

  test "global" do
    config = @config.global(DataCenter::DALLAS)
    assert_equal "localhost", config.hostname
    assert_equal "pardot_global_functional", config.database
    assert config.username.starts_with?("$1:gf9sLJieU"), "invalid username"
    assert config.password.starts_with?("$1:wZIySl8/m"), "invalid password"

    assert_raise(DatabaseConfiguration::DataCenterNotFound) do
      @config.global("brussels")
    end
  end

  test "shard" do
    config = @config.shard(DataCenter::SEATTLE, 1)
    assert_equal "localhost", config.hostname
    assert_equal "pardot_shard1_functional", config.database
    assert config.username.starts_with?("$1:tEi9hqXRRD"), "invalid username"
    assert config.password.starts_with?("$1:E0MqXLFZvW"), "invalid password"

    assert_raise(DatabaseConfiguration::ShardNotFound) do
      @config.shard(DataCenter::SEATTLE, 3)
    end

    assert_raise(DatabaseConfiguration::DataCenterNotFound) do
      @config.shard("brussels", 1)
    end
  end
end
