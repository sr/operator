module Pardot
  module PullAgent
    module Environments
      class Dev < Base
      end

      register(:dev, Dev)
    end
  end
end
