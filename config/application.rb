require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv.load

require "instrumentation"

module Dbquery
  class Application < Rails::Application
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.schema_format = :ruby

    initializer "instrumentation_library" do
      Instrumentation.setup(Rails.env)

      config.middleware.insert_after ::ActionDispatch::RequestId, \
        Instrumentation::RequestId::RackMiddleware
    end

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      {
        :request_id => event.payload[:request_id],
      }
    end
  end
end
