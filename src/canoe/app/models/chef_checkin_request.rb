class ChefCheckinRequest
  Checkout = Struct.new(:sha, :branch, :last_modified)

  def self.from_hash(request)
    checkout = request.fetch("checkout")
    mtime = Integer(checkout.fetch("mtime"))

    new(
      request.fetch("environment"),
      Checkout.new(
        checkout.fetch("sha"),
        checkout.fetch("branch"),
        Time.at(mtime)
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

  def checkout_older_than?(max_age)
    (Time.now - @checkout.last_modified) > max_age
  end
end
