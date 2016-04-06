if defined?(Rails::Railtie)
  require "instrumentation/railtie"
end

module Instrumentation
  autoload :Logging, "instrumentation/logging"
  autoload :RequestId, "instrumentation/request_id"

  def setup(env)
    Logging.setup(env)
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

  def log_exception(exception, data = {}, &block)
    if !data.respond_to?(:to_hash)
      raise ArgumentError, "invalid data: #{data.inspect}"
    end
    Logging.log_exception(exception, data.to_hash, &block)
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
