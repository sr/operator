module Strategies
  module Fetch
    class Base
      attr_reader :environment

      def initialize(environment)
        @environment = environment
      end

      def valid?(deploy)
        # returns boolean value indicating the combination is valid
        raise "Must be defined by sub-classes"
      end

      def fetch(deploy)
        # returns path to fetched asset (file or directory)
        raise "Must be defined by sub-classes"
      end

      def type
        self.class.to_s.split("::").last.downcase.to_sym
      end
    end
  end
end
