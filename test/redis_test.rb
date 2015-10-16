require_relative "test_helper.rb"
require "redis"

describe Redis do
  before do
    Console.silence!
    @r = Redis::Host.new('localhost', 6379)
  end

  it ".hset" do
    socket = mock()
    socket.stubs(:read)
    socket.expects(:puts).with("HSET foo bar baz\r\nQUIT\r\n")
    TCPSocket.stubs(:open).yields(socket)
    @r.hset("foo", "bar", "baz")
  end

  it ".set" do
    socket = mock()
    socket.stubs(:read)
    socket.expects(:puts).with("SET foo bar\r\nQUIT\r\n")
    TCPSocket.stubs(:open).yields(socket)
    @r.set("foo", "bar")
  end

  it ".has_key?" do
    socket = mock()
    socket.stubs(:read)
    socket.expects(:puts).with("EXISTS mykey\r\nQUIT\r\n")
    TCPSocket.stubs(:open).yields(socket)
    @r.has_key?("mykey")
  end

  it ".set with db" do
    socket = mock()
    socket.stubs(:read)
    socket.expects(:puts).with("SELECT 10\r\nSET foo bar\r\nQUIT\r\n")
    TCPSocket.stubs(:open).yields(socket)
    r = Redis::Host.new('localhost', 6379, 10)
    r.set("foo", "bar")
  end

  it "Bounce workers use a default redis port" do
    redis_host = mock
    redis_host.stubs(:has_key?).returns(true)
    redis_host.expects(:hset).returns(true)
    Redis::Host.expects(:new).with("localhost", 6379).returns(redis_host)
    Redis.bounce_workers("automationWorkers", ["localhost"])
  end

  it "Bounce workers should be able to handle port numbers" do
    redis_host = mock
    redis_host.stubs(:has_key?).returns(true)
    redis_host.expects(:hset).returns(true)
    Redis::Host.expects(:new).with("localhost", 1234).returns(redis_host)
    Redis.bounce_workers("automationWorkers", ["localhost:1234"])
  end

  it "Bounce workers should be able to handle ranges" do
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
