require "test_helper"

class DatabaseConfigurationFileTest < ActiveSupport::TestCase
  setup do
    @config = DatabaseConfigurationFile.load
  end

  test "global" do
    config = @config.global(DataCenter::DALLAS)
    assert_equal "mysql", config.hostname
    assert_equal "pardot_global", config.name
    assert_equal "root", config.username
    assert_nil config.password

    assert_raise(DatabaseConfigurationFile::DataCenterNotFound) do
      @config.global("brussels")
    end
  end

  test "shard" do
    config = @config.shard(DataCenter::SEATTLE, 1)
    assert_equal "mysql", config.hostname
    assert_equal "pardot_shard1", config.name
    assert_equal "root", config.username
    assert_nil config.password

    assert_raise(DatabaseConfigurationFile::ShardNotFound) do
      @config.shard(DataCenter::SEATTLE, 3)
    end

    assert_raise(DatabaseConfigurationFile::DataCenterNotFound) do
      @config.shard("brussels", 1)
    end
  end
end
