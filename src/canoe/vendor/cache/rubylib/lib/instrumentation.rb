module Instrumentation
  # Simple key-value text based logging format. See https://brandur.org/logfmt
  LOG_LOGFMT = :logfmt

  # Logstash JSON logging format
  LOG_LOGSTASH = :logstash

  # No-op log formatter, that returns the log data unmodified as a Ruby hash
  LOG_NOOP = :noop

  autoload :Logging, "instrumentation/logging"
  autoload :RequestId, "instrumentation/request_id"

  def setup(app_name, env, options = {})
    log_format = options.fetch(:log_format, LOG_LOGFMT)

    Logging.setup(app_name, env, log_format)
  end

  def context(data, &block)
    Logging.context(data, &block)
  end

  def log(data, &block)
    Logging.log(data, &block)
  end

  def error(code, data, &block)
    log(data.merge(level: "error", error: code), &block)
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
    :log_exception,
    :error,
    :request_id,
    :request_id=
end

if defined?(Rails::Railtie)
  require "instrumentation/railtie"
end
