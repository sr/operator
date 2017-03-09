require "rails"
require "lograge"

module Instrumentation
  class Railtie < Rails::Railtie
    config.instrumentation = ActiveSupport::OrderedOptions.new
    config.instrumentation.log_format = Instrumentation::LOG_LOGFMT

    initializer "instrumentation_library" do
      app_name = Rails.application.class.parent_name.downcase

      Instrumentation.setup(
        app_name,
        Rails.env.to_str,
        config.instrumentation.to_hash
      )

      config.app_middleware.insert_after ::ActionDispatch::RequestId, \
        Instrumentation::RequestId::RackMiddleware

      config.lograge.enabled = true

      if config.instrumentation.log_format == Instrumentation::LOG_LOGSTASH
        config.lograge.formatter = Lograge::Formatters::Logstash.new
      end

      config.lograge.custom_options = lambda do |event|
        data = {
          app: app_name,
          env: Rails.env.to_str,
          request_id: Instrumentation.request_id
        }

        context = event.payload[:context]
        if context.respond_to?(:each)
          context.each do |key, value|
            data[key] = value
          end
        end

        data
      end
    end
  end
end
