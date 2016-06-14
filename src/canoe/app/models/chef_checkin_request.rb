class ChefCheckinRequest
  Checkout = Struct.new(:sha, :branch)

  def self.from_hash(request)
    checkout = request.fetch("checkout")

    new(
      request.fetch("environment"),
      Checkout.new(
        checkout.fetch("sha"),
        checkout.fetch("branch")
      )
    )
  end

  def initialize(environment, checkout)
    @environment = environment
    @checkout = checkout
  end

  attr_reader :environment, :checkout

  def checkout_sha
    @checkout.sha
  end

  def checkout_branch
    @checkout.branch
  end
end
