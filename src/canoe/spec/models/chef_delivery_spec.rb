require "rails_helper"

RSpec.describe ChefDelivery do
  before(:each) do
    @repo = FakeGithubRepository.new
    @config = FakeChefDeliveryConfig.new(@repo)
    @delivery = ChefDelivery.new(@config)
  end

  def build_build(attributes={})
    defaults = {
      url: "https://github.com/builds/1",
      sha: "sha1",
      state: "success"
    }
    GithubRepository::Build.new(defaults.merge(attributes))
  end

  def build_deploy(attributes={})
    defaults = {
      url: "https://github.com/deploys/1",
      environment: "testing",
      branch: "master",
      sha: "sha1",
      state: "success"
    }
    GithubRepository::Deploy.new(defaults.merge(attributes))
  end

  it "noops if chef delivery is disabled in current environment" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("dfw", checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if there is no available build" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = GithubRepository::Build.none
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is red" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build(state: "failure")
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build(state: "pending")
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if non-master branch has been checked out for less than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "noops and notifies if non-master branch has been checked out for more than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom", 2.hours.ago)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert msg.message.include?("not deployed")
  end

  it "deploys if there is no deploy available" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build(state: "success")
    @repo.current_deploy = GithubRepository::Deploy.none
    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
    deploy = response.deploy
    assert_equal "sha1", deploy.sha
    assert_equal "testing", deploy.environment
  end

  pending "TODO(sr) noop and notifies if the deploy could not be created"

  it "noops if current deploy is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build
    @repo.current_deploy = build_deploy(state: GithubRepository::PENDING)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if current sha1 is already deployed" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = build_build(sha: "sha1")
    @repo.current_deploy = build_deploy(sha: "sha1")
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  pending "TODO(sr) current build is already deployed but the deploy failed"

  it "notifies of successful deployment" do
    request = ChefCompleteDeployRequest.new(build_deploy, nil)
    response = @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("successfully deployed")
  end

  it "notifies of failed deployment" do
    request = ChefCompleteDeployRequest.new(build_deploy, "boomtown")
    response = @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("failed to deploy")
    assert message.message.include?("boomtown")
  end

  it "notifies if unable to update github deployment" do
    request = ChefCompleteDeployRequest.new(build_deploy, nil)
    @repo.complete_deploy = GithubRepository::CompleteResponse.new(false, "boomtown github")
    response = @delivery.complete_deploy(request)
    assert_equal 1, @config.notifier.messages.size
    message = @config.notifier.messages.pop
    assert message.message.include?("failed to deploy")
    assert message.message.include?("update GitHub deployment")
    assert message.message.include?("boomtown github")
  end
end
