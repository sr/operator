require "thread"

module Lita
  module Adapters
    # Adapter that does nothing. Useful for starting just the web portion of Lita.
    class Nothing < Adapter
      def initialize(robot)
        super

        @mutex = Mutex.new
        @resource = ConditionVariable.new
      end

      def run
        @mutex.synchronize do
          @resource.wait(@mutex)
        end
      end

      def shut_down
        @mutex.synchronize do
          @resource.signal
        end
      end
    end

    Lita.register_adapter(:nothing, Nothing)
  end
end
