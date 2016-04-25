module Pardot
  module PullAgent
    module Environments
      class Test < Base
      end

      register(:test, Test)
    end
  end
end
