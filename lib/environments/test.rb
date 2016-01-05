require_relative "base"

module Environments
  class Test < Base
  end

  register(:test, Test)
end
