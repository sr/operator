require "rails_helper"

RSpec.describe ChefDelivery do
  before(:each) do
    @repo = FakeGithubRepository.new
    @config = FakeChefDeliveryConfig.new(@repo)
    @delivery = ChefDelivery.new(@config)
  end

  test "noops if chef delivery is disabled in current environment" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("dfw", checkout)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if there is no available build" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    @repo.current_build = GithubRepository::Build.new(nil, nil)
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is red" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = ChefDelivery::GithubRepository::Build.new("sha1", "failure")
    @repo.current_build = build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if the build is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = ChefDelivery::GithubRepository::Build.new("sha1", "pending")
    @repo.current_build = build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  it "noops if non-master branch has been checked out for less than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = ChefDelivery::GithubRepository::Build.new("sha1", "green")
    @repo.current_build = build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 0, @config.notifier.messages.size
  end

  it "noops and notifies if non-master branch has been checked out for more than an hour" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "boom", 2.hours.ago)
    request = ChefCheckinRequest.new("testing", checkout)
    build = ChefDelivery::GithubRepository::Build.new("sha1", "success")
    @repo.current_build = build
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
    assert_equal 1, @config.notifier.messages.size
    msg = @config.notifier.messages.pop
    assert_equal "boom", msg
  end

  it "deploys if there is no deploy available" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = GithubRepository::Build.new("sha1", "success")
    deploy = GithubRepository::Deploy.new(request.environment, nil, nil)
    @repo.current_build = build
    @repo.current_deploy = deploy
    response = @delivery.checkin(request)
    assert_equal "deploy", response.action
    deploy = response.deploy
    assert_equal "sha1", deploy.sha
    assert_equal "testing", deploy.environment
  end

  pending "noops and notifies if the deploy could not be created"

  pending "redeploys if the last deploy failed"

  it "noops if current deploy is pending" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = GithubRepository::Build.new("sha1", "success")
    deploy = GithubRepository::Deploy.new(request.environment, build.sha, "pending")
    @repo.current_build = build
    @repo.current_deploy = deploy
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  test "noops if current sha1 is already deployed" do
    checkout = ChefCheckinRequest::Checkout.new("sha1", "master", Time.now)
    request = ChefCheckinRequest.new("testing", checkout)
    build = ChefDelivery::GithubRepository::Build.new("sha1", "success")
    deploy = ChefDelivery::GithubRepository::Deploy.new(request.environment, build.sha, "success")
    @repo.current_build = build
    @repo.current_deploy = deploy
    response = @delivery.checkin(request)
    assert_equal "noop", response.action
  end

  pending "TODO if current is already deployed but deploy failed"
end
