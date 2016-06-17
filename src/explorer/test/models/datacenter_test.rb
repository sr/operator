require "test_helper"

class DatacenterTest < ActiveSupport::TestCase
  setup do
    @datacenter = Datacenter.current
  end

  test "account not authorized by fixtures" do
    assert_not @datacenter.account_access_enabled?(1)
  end

  test "account authorized after adding unexpiring access" do
    authorize_access(1)
    assert @datacenter.account_access_enabled?(1)
  end

  test "account authorized after adding expiring access" do
    authorize_access(1, nil, 1.minute.ago.end_of_day.to_s(:db))
    assert @datacenter.account_access_enabled?(1)
  end

  test "log for system queries" do
    Datacenter.current.accounts

    assert log = Instrumentation::Logging.entries.pop
    assert_equal "SELECT id, shard_id, company FROM global_account LIMIT 100", log[:query]
    assert_equal "pardot_global", log[:database]
    assert_equal [], log[:params]
    assert_not log[:user_email], "system log entry should not have a user_email key"
  end
end
