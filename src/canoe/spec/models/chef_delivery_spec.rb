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
      environment: "testing",
      sha: "sha1",
      state: ChefDelivery::SUCCESS
    }
    ChefDeploy.create!(defaults.merge(attributes))
  end

  it "noops if chef delivery is disabled in current environment" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("dfw", "chef1", checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if chef delivery isn't enabled for the host" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("dfw", "disabled", checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if there is no available build" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = GithubRepository::Build.none
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is red" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build(state: ChefDelivery::FAILURE)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build(state: ChefDelivery::PENDING)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if non-master branch has been checked out for less than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "noops and notifies if non-master branch has been checked out for more than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new("testing", "pardot0-chef1", checkout)
    @repo.current_build = build_build(updated_at: 90.minutes.ago)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert msg.message.include?("not deployed")
    assert msg.message.include?("pardot0-chef1")
  end

  it "noops and doesn't notify if non-master branch has been checkout for less than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom")
    request = ChefCheckinRequest.new("testing", "pardot0-chef1", checkout)
    @repo.current_build = build_build(updated_at: 30.minutes.ago)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "deploys if there is no deploy available" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build(state: ChefDelivery::SUCCESS)
    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
    deploy = response.deploy
    assert_equal "sha1", deploy.sha
    assert_equal "testing", deploy.environment
  end

  it "noops if current deploy is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build
    create_current_deploy(state: ChefDelivery::PENDING)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current sha1 is already deployed" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new("testing", "chef1", checkout)
    @repo.current_build = build_build(sha: "sha1")
    create_current_deploy(state: ChefDelivery::SUCCESS, sha: "sha1")
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "notifies of successful deployment" do
    deploy = create_current_deploy(state: ChefDelivery::PENDING)
    request = ChefCompleteDeployRequest.new("chef1", deploy, nil)
    @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("successfully deployed")
  end

  it "notifies of failed deployment" do
    deploy = create_current_deploy(state: ChefDelivery::PENDING)
    request = ChefCompleteDeployRequest.new("chef1", deploy, "boomtown")
    @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("failed to deploy")
    assert message.message.include?("boomtown")
  end
end
