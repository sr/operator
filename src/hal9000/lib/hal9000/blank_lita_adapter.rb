require "lita"
require "thread"

module Hal9000
  # Adapter that does nothing. Useful for starting just the web portion of Lita.
  class BlankLitaAdapter < Lita::Adapter
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

    Lita.register_adapter(:blank, self)
  end
end
