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

        def list_servers(target, repo_name)
          ["localhost"]
        end

        def perform(deploy)
          @deploys << deploy
          nil
        end

        def clear
          @deploys.clear
        end
      end
    end
  end
end
