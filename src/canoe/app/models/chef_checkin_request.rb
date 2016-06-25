class ChefCheckinRequest
  Checkout = Struct.new(:sha, :branch)

  def self.from_hash(request)
    checkout = request.fetch("checkout")
    server = request.fetch("server")

    new(
      ChefDelivery::Server.new(
        server.fetch("datacenter"),
        server.fetch("environment"),
        server.fetch("hostname")
      ),
      Checkout.new(
        checkout.fetch("sha"),
        checkout.fetch("branch")
      )
    )
  end

  def initialize(server, checkout)
    @server = server
    @checkout = checkout
  end

  attr_reader :checkout, :server

  def checkout_sha
    @checkout.sha
  end

  def checkout_branch
    @checkout.branch
  end
end
