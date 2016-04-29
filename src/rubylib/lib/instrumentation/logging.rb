require "logstash/event"
require "scrolls"

module Instrumentation
  module Logging
    class UnsupportedFormat < StandardError
      def initialize(format)
        super "log format #{format.inspect} is not supported"
      end
    end

    module LogstashFormatter
      def unparse(data)
        LogStash::Event.new(data).to_json
      end
    end

    def RawFormatter
      def unparse(data)
        data
      end
    end

    def setup(app_name, env_name, format)
      stream =
        case env_name
        when "test"
          FakeStream.new
        else
          STDOUT
        end

      Scrolls.init(
        stream: stream,
        exceptions: "single",
        global_context: {
          app: app_name,
          env: env_name
        }
      )

      case format
      when LOG_NOOP
        Scrolls::Log.extend RawFormatter
      when LOG_LOGSTASH
        Scrolls::Log.extend LogstashFormatter
      when LOG_LOGFMT
        # Use Scrolls::Parser
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

    def log_exception(exception, data, &block)
      @logger.log_exception(exception, data, &block)
    end

    def reset
      @stream.reset
    end

    def entries
      @stream.entries
    end

    module_function :setup, :context, :log, :reset, :entries

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
