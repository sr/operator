require "redis"

describe Redis do
  before do
    @r = Redis::Host.new('localhost', 6379)
  end

  specify ".hset" do
    TCPServer.open("127.0.0.1", 0) do |sock|
      Thread.new do
        host = Redis::Host.new("127.0.0.1", sock.addr[1])
        host.hset("foo", "bar", "baz")
      end

      s = sock.accept
      expect(s.readline).to eq("HSET foo bar baz\r\n")
      expect(s.readline).to eq("QUIT\r\n")
    end
  end

  specify ".set" do
    TCPServer.open("127.0.0.1", 0) do |sock|
      Thread.new do
        host = Redis::Host.new("127.0.0.1", sock.addr[1])
        host.set("foo", "bar")
      end

      s = sock.accept
      expect(s.readline).to eq("SET foo bar\r\n")
      expect(s.readline).to eq("QUIT\r\n")
    end
  end

  it ".set with db" do
    TCPServer.open("127.0.0.1", 0) do |sock|
      Thread.new do
        host = Redis::Host.new("127.0.0.1", sock.addr[1], 10)
        host.set("foo", "bar")
      end

      s = sock.accept
      expect(s.readline).to eq("SELECT 10\r\n")
      expect(s.readline).to eq("SET foo bar\r\n")
      expect(s.readline).to eq("QUIT\r\n")
    end
  end

  describe ".has_key?" do
    it "returns true when the key exists" do
      TCPServer.open("127.0.0.1", 0) do |sock|
        Thread.new do
          s = sock.accept
          s.readline
          s.write(":1\r\n")
          s.readline
          s.close
        end

        host = Redis::Host.new("127.0.0.1", sock.addr[1])
        expect(host.has_key?("foo")).to be_truthy
      end
    end

    it "returns false when the key exists" do
      TCPServer.open("127.0.0.1", 0) do |sock|
        Thread.new do
          s = sock.accept
          s.readline
          s.write("0r\n")
          s.readline
          s.close
        end

        host = Redis::Host.new("127.0.0.1", sock.addr[1])
        expect(host.has_key?("foo")).to be_falsey
      end
    end
  end
end
