module Canoe
  module Deployment
    module Strategies
      # The Test strategy adds the deployment to a list that can be inspected in
      # a test assertion.
      class Test
        attr_reader :deploys

        def initialize
          @deploys = []
        end

        def list_servers(target)
          ["localhost"]
        end

        def perform(deploy, lock: false)
          @deploys << deploy
          nil
        end

        def lock(target:, user:)
          "test lock successful"
        end

        def unlock(target:, user:, force:)
          "test unlock successful"
        end

        def clear
          @deploys.clear
        end
      end
    end
  end
end
