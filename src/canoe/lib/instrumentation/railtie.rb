require "rails"
require "lograge"

module Instrumentation
  class Railtie < Rails::Railtie
    initializer "instrumentation_library" do
      app_name = Rails.application.class.parent_name.downcase
      Instrumentation.setup(app_name, Rails.env.to_str)

      config.app_middleware.insert_after ::ActionDispatch::RequestId, \
        Instrumentation::RequestId::RackMiddleware

      config.lograge.enabled = true
      config.lograge.custom_options = lambda do |event|
        {
          :app => app_name,
          :env => Rails.env.to_str,
          :request_id => Instrumentation.request_id
        }
      end
    end
  end
end
