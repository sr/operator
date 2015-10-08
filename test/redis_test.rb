require_relative "test_helper.rb"
require "redis"

describe Redis do
  before do
    Console.silence!
  end

  it "Bounce workers use a default redis port" do
    Redis.stubs(:redis_installed?).returns(true)
    redis_host = mock
    redis_host.stubs(:has_key?).returns(true)
    redis_host.expects(:hset).returns(true)
    Redis::Host.expects(:new).with("localhost", 6379).returns(redis_host)
    Redis.bounce_workers("automationWorkers", ["localhost"])
  end

  it "Bounce workers should be able to handle port numbers" do
    Redis.stubs(:redis_installed?).returns(true)
    redis_host = mock
    redis_host.stubs(:has_key?).returns(true)
    redis_host.expects(:hset).returns(true)
    Redis::Host.expects(:new).with("localhost", 1234).returns(redis_host)
    Redis.bounce_workers("automationWorkers", ["localhost:1234"])
  end

  it "Bounce workers should be able to handle ranges" do
    Redis.stubs(:redis_installed?).returns(true)
    redis_host = mock
    redis_host_false = mock
    redis_host_false.stubs(:has_key?).returns(false)
    redis_host.stubs(:has_key?).returns(true)
    redis_host.expects(:hset).returns(true)
    Redis::Host.expects(:new).with("localhost", 1234).returns(redis_host_false)
    Redis::Host.expects(:new).with("localhost", 1235).returns(redis_host)
    Redis::Host.expects(:new).with("localhost", 1236).returns(redis_host).never
    Redis::Host.expects(:new).with("localhost", 1237).returns(redis_host).never
    Redis.bounce_workers("automationWorkers", ["localhost:1234..1237"])
  end
end
