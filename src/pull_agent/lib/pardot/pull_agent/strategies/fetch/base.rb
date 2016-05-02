module Pardot
  module PullAgent
    module Strategies
      module Fetch
        class Base
          attr_reader :environment

          def initialize(environment)
            @environment = environment
          end

          def valid?(_deploy)
            # returns boolean value indicating the combination is valid
            fail "Must be defined by sub-classes"
          end

          def fetch(_deploy)
            # returns path to fetched asset (file or directory)
            fail "Must be defined by sub-classes"
          end

          # Cleans up any temporary files
          def cleanup(_deploy)
          end

          def type
            self.class.to_s.split("::").last.downcase.to_sym
          end
        end
      end
    end
  end
end
