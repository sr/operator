module Pardot
  module PullAgent
    module Strategies
      module Deploy
        class Base
          attr_reader :environment

          def initialize(environment)
            @environment = environment
          end

          def deploy(_path, _deploy)
            fail "Must be defined by sub-classes"
          end

          def rollback?(_deploy)
            false
          end
        end
      end
    end
  end
end
