require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "instrumentation"

module Dbquery
  class Application < Rails::Application
    config.time_zone = "Eastern Time (US & Canada)"
    config.active_record.schema_format = :ruby
  end
end
