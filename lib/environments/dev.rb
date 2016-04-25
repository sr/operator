require_relative "base"

module Environments
  class Dev < Base
  end

  register(:dev, Dev)
end
