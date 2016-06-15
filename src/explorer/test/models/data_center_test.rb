require "test_helper"

class DataCenterTest < ActiveSupport::TestCase
  setup do
    @datacenter = DataCenter.new(
      Rails.application.config.x.datacenter,
      DatabaseConfigurationFile.load
    )
  end

  test "account authorized not authorized by fixtures" do
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
end