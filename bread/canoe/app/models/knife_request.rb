class KnifeRequest
  def self.from_hash(request)
    server = request.fetch("server")

    new(
      ChefDelivery::Server.new(
        server.fetch("datacenter"),
        server.fetch("environment"),
        server.fetch("hostname")
      ),
      request.fetch("command"),
    )
  end

  def initialize(server, command)
    @server = server
    @command = command
  end

  attr_reader :server, :command
end
