require "rails_helper"

RSpec.describe ChefDelivery do
  before(:each) do
    @repo = GithubRepository::Fake.new
    @config = FakeChefDeliveryConfig.new(@repo)
    @delivery = ChefDelivery.new(@config)
  end

  def build_build(attributes = {})
    defaults = {
      url: "https://github.com/builds/1",
      sha: "sha1",
      state: ChefDelivery::SUCCESS,
      updated_at: Time.current
    }
    GithubRepository::Build.new(defaults.merge(attributes))
  end

  def create_current_deploy(attributes = {})
    defaults = {
      branch: "master",
      build_url: "https://github/builds/1",
      datacenter: "test",
      environment: "testing",
      hostname: "test0-chef1-1",
      sha: "sha1",
      state: ChefDelivery::SUCCESS
    }
    ChefDeploy.create!(defaults.merge(attributes))
  end

  it "noops if chef delivery is disabled in current environment" do
    server = ChefDelivery::Server.new("dfw", "disabled", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if chef delivery is not enabled for the server" do
    server = ChefDelivery::Server.new("test", "production", "disabled")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if there is no available build" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = GithubRepository::Build.none
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is red" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(state: ChefDelivery::FAILURE)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is pending" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(state: ChefDelivery::PENDING)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if non-master branch has been checked out for less than an hour" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "noops and notifies if non-master branch has been checked out for more than an hour" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(updated_at: 90.minutes.ago)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert msg.message.include?("not deployed")
    assert msg.message.include?("pardot0-chef1")
  end

  it "noops and doesn't notify if non-master branch has been checkout for less than an hour" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(updated_at: 30.minutes.ago)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "noops if there is no build available" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = GithubRepository::Build.none
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current deploy is pending" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build
    create_current_deploy(state: ChefDelivery::PENDING)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current sha1 is already deployed" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(sha: "sha1")
    create_current_deploy(state: ChefDelivery::SUCCESS, sha: "sha1")
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "deploys if the current deploy is successful but differs from current build" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    @repo.current_build = build_build(sha: "sha2")
    create_current_deploy(state: ChefDelivery::SUCCESS, sha: "sha1")
    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
  end

  it "notifies of successful deployment" do
    deploy = create_current_deploy(state: ChefDelivery::PENDING)
    request = ChefCompleteDeployRequest.new(deploy.id, true, nil)
    @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("successfully deployed")
  end

  it "notifies of failed deployment" do
    deploy = create_current_deploy(state: ChefDelivery::PENDING)
    request = ChefCompleteDeployRequest.new(deploy.id, false, "boomtown")
    @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert msg.message.include?("failed to deploy")
    assert msg.message.include?("boomtown")
  end
end
