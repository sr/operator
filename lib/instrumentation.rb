module Instrumentation
  autoload :Logging, "instrumentation/logging"
  autoload :RequestId, "instrumentation/request_id"

  def setup(rails_env)
    Logging.setup(rails_env)
  end

  def log(data, &block)
    Logging.log(data, &block)
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
    :request_id,
    :request_id=
end
