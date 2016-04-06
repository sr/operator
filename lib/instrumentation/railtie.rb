require "rails"

module Instrumentation
  class Railtie < Rails::Railtie
    initializer "instrumentation_library" do
      Instrumentation.setup(Rails.env)

      config.app_middleware.insert_after ::ActionDispatch::RequestId, \
        Instrumentation::RequestId::RackMiddleware

      config.lograge.enabled = true
      config.lograge.custom_options = lambda do |event|
        {
          :request_id => Instrumentation.request_id
        }
      end
    end
  end
end
