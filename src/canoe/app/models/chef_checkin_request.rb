class ChefCheckinRequest
  Checkout = Struct.new(:sha, :branch)

  def self.from_hash(request)
    checkout = request.fetch("checkout")

    new(
      request.fetch("environment"),
      request.fetch("hostname"),
      Checkout.new(
        checkout.fetch("sha"),
        checkout.fetch("branch")
      )
    )
  end

  def initialize(environment, hostname, checkout)
    @environment = environment
    @hostname = hostname
    @checkout = checkout
  end

  attr_reader :hostname, :environment, :checkout

  def checkout_sha
    @checkout.sha
  end

  def checkout_branch
    @checkout.branch
  end
end
