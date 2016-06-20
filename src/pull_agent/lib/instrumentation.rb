module Instrumentation
  # Simple key-value text based logging format. See https://brandur.org/logfmt
  LOG_LOGFMT = :logfmt

  # Logstash JSON logging format
  LOG_LOGSTASH = :logstash

  # No-op log formatter, that returns the log data unmodified as a Ruby hash
  LOG_NOOP = :noop

  SYSLOG = "syslog".freeze

  DEBUG = "debug".freeze
  ERROR = "error".freeze

  autoload :Logging, "instrumentation/logging"
  autoload :RequestId, "instrumentation/request_id"

  def setup(app_name, env_name, options = {})
    log_format = options.fetch(:log_format, LOG_LOGFMT)
    log_stream =
      case options[:log_stream]
      when :fake
        FakeStream.new
      when :syslog
        SYSLOG
      else
        if options[:log_stream].respond_to?(:puts)
          options[:log_stream]
        else
          STDOUT
        end
      end

    Logging.setup(log_stream, log_format, app: app_name, env: env_name)
  end

  def context(data, &block)
    Logging.context(data, &block)
  end

  def log(data, &block)
    Logging.log(data, &block)
  end

  def debug(data, &block)
    log(data.merge(level: DEBUG), &block)
  end

  def error(data, &block)
    log(data.merge(level: ERROR), &block)
  end

  def log_exception(exception, data = {})
    if !data.respond_to?(:to_hash)
      raise ArgumentError, "invalid data: #{data.inspect}"
    end
    Logging.log_exception(exception, data.to_hash)
  end

  def request_id
    RequestId.request_id
  end

  def request_id=(value)
    RequestId.request_id = value
  end

  module_function \
    :setup,
    :context,
    :log,
    :error,
    :debug,
    :log_exception,
    :error,
    :request_id,
    :request_id=
end

if defined?(Rails::Railtie)
  require "instrumentation/railtie"
end
