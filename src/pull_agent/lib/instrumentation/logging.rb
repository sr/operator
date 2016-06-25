require "logstash/event"
require "scrolls"

module Instrumentation
  module Logging
    class UnsupportedFormat < StandardError
      def initialize(format)
        super "log format #{format.inspect} is not supported"
      end
    end

    def setup(stream, format, context)
      Scrolls.init(stream: stream, exceptions: "single", global_context: context)

      case format
      when LOG_NOOP
        Scrolls::Log.module_eval do
          def self.unparse(data)
            data
          end
        end
      when LOG_LOGSTASH
        Scrolls::Log.module_eval do
          def self.unparse(data)
            LogStash::Event.new(data).to_json
          end
        end
      when LOG_LOGFMT
        Scrolls::Log.module_eval do
          def self.unparse(data)
            Scrolls::Parser.unparse(data)
          end
        end
      else
        raise UnsupportedFormat, format
      end

      @stream = stream
      @logger = Scrolls
    end

    def context(data, &block)
      @logger.context(data, &block)
    end

    def log(data, &block)
      @logger.log(data, &block)
    end

    def log_exception(exception, data)
      @logger.log_exception(data, exception)
    end

    def reset
      if @stream.respond_to?(:reset)
        @stream.reset
      end
    end

    def entries
      @stream.entries
    end

    module_function :setup, :context, :log, :log_exception, :reset, :entries

    class FakeStream
      def initialize
        @entries = []
      end

      attr_reader :entries

      def reset
        @entries.clear
      end

      def sync=(_)
      end

      def puts(data)
        @entries << data
        if block_given?
          yield
        end
      end
    end
  end
end
