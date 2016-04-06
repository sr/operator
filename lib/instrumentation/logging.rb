require "scrolls"

module Instrumentation
  module Logging
    def setup(env)
      @logger =
        if env == "test"
          FakeLogger.new
        else
          Scrolls.init(
            stream: STDOUT,
            exceptions: "single",
          )
          Scrolls
        end
    end

    def context(data, &block)
      @logger.context(data, &block)
    end

    def log(data, &block)
      @logger.log(data, &block)
    end

    def log_exception(exception, data, &block)
      @logger.log_exception(exception, data, &block)
    end

    def reset
      @logger.reset
    end

    def entries
      @logger.entries
    end

    module_function :setup, :context, :log, :reset, :entries

    class FakeLogger
      def initialize
        @entries = []
        @context = {}
      end

      attr_reader :entries

      def reset
        @entries.clear
        @context.clear
      end

      def context(data)
        @context = data
        yield
      end

      def log(data)
        @entries << data.merge(@context)
        if block_given?
          yield
        end
      end
    end
  end
end
