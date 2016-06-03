require "rails_helper"

RSpec.describe ChefDelivery do
  before(:each) do
    @chef = ChefDelivery.new(ChefDeliveryConfig.new)
  end

  test "noops if chef delivery is disabled in current environment" do
  end

  test "noops if current sha1 is already deployed" do
  end

  test "deployed sha1 matches latest build sha1" do
    request = ChefCheckinRequest.new("dfw", ChefCheckinRequest::Checkout.new("sha1", "master", Time.now))
    response = @chef.checkin(request)
    assert_equal "noop", response.action
  end

  test "non-master branch has been checked out for more than an hour" do
    request = ChefCheckinRequest.new("dfw", ChefCheckinRequest::Checkout.new("sha1", "master", Time.now))
    response = @chef.checkin(request)
    assert_equal "noop", response.action
  end

  test "non-master branch has been checked for less than an hour" do
  end

  test "latest master build is red" do
  end

  test "master is green, master is checked out, and sha1s do not match" do
  end
end
