require "rails_helper"

RSpec.describe ChefDelivery do
  before(:each) do
    @config = FakeChefDeliveryConfig.new
    @delivery = ChefDelivery.new(@config)

    github.tests_state = GithubRepository::SUCCESS
  end

  def github
    Canoe.config.github_client
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
    github.tests_state = nil

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is red" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.tests_state = GithubRepository::FAILURE

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is pending" do
    server = ChefDelivery::Server.new("test", "production", "chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.tests_state = GithubRepository::PENDING

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops and notifies once every 30 minutes if non-master branch is checked out" do
    create_current_deploy(state: ChefDelivery::SUCCESS, sha: "sha^^^")
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "mybranch")
    request = ChefCheckinRequest.new(server, checkout)
    github.master_head_sha = "deadbeef"

    response = @delivery.checkin(request, Time.current)
    assert_equal "noop", response.action
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "could not be deployed"
    assert_includes msg.message, "mybranch"
    assert_includes msg.message, "pardot0-chef1"

    response = @delivery.checkin(request, Time.current + 15.minutes)
    assert_equal 0, @config.notifier.messages.size
    assert_equal "noop", response.action

    response = @delivery.checkin(request, Time.current + 40.minutes)
    assert_equal 1, @config.notifier.messages.size
    assert_equal "noop", response.action
  end

  it "noops if there is no build available" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.tests_state = nil

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current deploy is pending" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    create_current_deploy(state: ChefDelivery::PENDING)

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current sha1 is already deployed" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.master_head_sha = "sha1"
    create_current_deploy(state: ChefDelivery::SUCCESS, sha: "sha1")

    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "deploys if the checkout differs from the current build" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.master_head_sha = "sha2"

    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
  end

  it "deploys the same build twice" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.master_head_sha = "sha1^^"

    response = @delivery.checkin(request)
    assert_equal "deploy", response.action

    request = ChefCompleteDeployRequest.new(response.deploy.id, true, nil)
    @delivery.complete_deploy(request)
    checkout = ChefCheckinRequest::Checkout.new("sha1~100", "master")
    request = ChefCheckinRequest.new(server, checkout)

    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
  end

  it "deploys to two chef servers within the same datacenter" do
    server = ChefDelivery::Server.new("test", "production", "pardot0-chef1")
    checkout = ChefCheckinRequest::Checkout.new("sha1^", "master")
    request = ChefCheckinRequest.new(server, checkout)
    github.master_head_sha = "sha1"

    response = @delivery.checkin(request)
    assert_equal "deploy", response.action

    request = ChefCompleteDeployRequest.new(response.deploy.id, true, nil)
    @delivery.complete_deploy(request)
    server = ChefDelivery::Server.new("test", "production", "pardot2-chef1")
    request = ChefCheckinRequest.new(server, checkout)

    response = @delivery.checkin(request)
    assert_equal "deploy", response.action

    request = ChefCompleteDeployRequest.new(response.deploy.id, true, nil)
    @delivery.complete_deploy(request)

    assert_equal 2, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "pardot2-chef1"
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "pardot0-chef1"
  end

  it "notifies of successful deployment" do
    deploy = create_current_deploy(
      state: ChefDelivery::PENDING,
      build_url: "https://BREAD-9000",
      hostname: "pardot0-chef1"
    )
    request = ChefCompleteDeployRequest.new(deploy.id, true, nil)
    @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "successfully deployed"
    assert_includes msg.message, "#9000"
    assert_includes msg.message, "pardot0-chef1"
  end

  it "notifies of failed deployment" do
    deploy = create_current_deploy(
      state: ChefDelivery::PENDING,
      hostname: "pardot0-chef1"
    )
    request = ChefCompleteDeployRequest.new(deploy.id, false, "boomtown")
    @delivery.complete_deploy(request)

    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "failed to deploy"
    assert_includes msg.message, "boomtown"
    assert_includes msg.message, "pardot0-chef1"
  end

  it "notifies of executed knife commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "pardot0-chef1")
    command = %w[environment from file fail.rb]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_includes msg.message, "dfw/dev"
    assert_includes msg.message, "knife #{command.join(" ")}"
    assert_includes msg.message, "pardot0-chef1"
  end

  it "ignores 'knife node from file' commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[node from file nodes/aws/node.json]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end

  it "ignores knife help commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[help list]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end

  it "ignores 'knife pd sync' command" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[pd sync]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end

  it "ignores 'knife search' commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[search hi andy]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end

  it "ignores 'knife node show' commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[node show pardot0-redisjob1-22-phx.ops.sfdc.net]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end

  it "ignores 'knife node list' commands" do
    server = ChefDelivery::Server.new("dfw", "dev", "chef1")
    command = %w[node list]
    request = KnifeRequest.new(server, command)
    @delivery.knife(request)
    assert_equal 0, @config.notifier.messages.size
  end
end
