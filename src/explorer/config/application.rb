require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "instrumentation"
require "canoe/ldap_authorizer"

module Explorer
  class Application < Rails::Application
    config.time_zone = "Eastern Time (US & Canada)"
    config.active_record.schema_format = :ruby

    if Rails.env.test?
      config.instrumentation.log_format = Instrumentation::LOG_NOOP
    else
      config.instrumentation.log_format = Instrumentation::LOG_LOGSTASH
    end

    initializer "explorer_app" do
      config.x.database_config = DatabaseConfigurationFile.load
      config.x.datacenter = ENV.fetch("EXPLORER_DATACENTER")
      config.x.authorized_ldap_groups = Array(ENV.fetch("EXPLORER_AUTHORIZED_LDAP_GROUPS").split(","))
      config.x.session_ttl = Integer(ENV.fetch("EXPLORER_SESSION_TTL")).minutes
    end
  end
end
