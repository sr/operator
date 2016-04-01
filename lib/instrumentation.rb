module Instrumentation
  autoload :Logging, "instrumentation/logging"
  autoload :RequestId, "instrumentation/request_id"

  def setup(rails_env)
    Logging.setup(rails_env)
  end

  def error(code, data, &block)
    log(data.merge(level: "info", error: code), &block)
  end

  def log(data, &block)
    Logging.log(data, &block)
  end

  def log_exception(exception, code = nil, data = {}, &block)
    if !data.respond_to?(:to_hash)
      raise ArgumentError, "invalid data: #{data.inspect}"
    end
    if code
      data[:code] = code
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
    :log,
    :error,
    :request_id,
    :request_id=
end
