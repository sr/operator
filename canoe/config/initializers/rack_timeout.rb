Rack::Timeout.service_timeout = Integer(ENV.fetch("RACK_TIMEOUT_SERVICE_TIMEOUT", 28))
