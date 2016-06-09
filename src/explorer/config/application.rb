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

    config.instrumentation.log_format = if Rails.env.test?
                                          Instrumentation::LOG_NOOP
                                        else
                                          Instrumentation::LOG_LOGSTASH
                                        end

    config.middleware.use Pinglish do |ping|
      ping.check :db do
        Integer(User.count)
      end
    end

    initializer "explorer_app" do
      config.x.database_config = DatabaseConfigurationFile.load
      config.x.datacenter = ENV.fetch("EXPLORER_DATACENTER")
      config.x.restricted_access_ldap_group = 'explorer_support'
      config.x.full_access_ldap_group = 'explorer_full'
      config.x.session_ttl = Integer(ENV.fetch("EXPLORER_SESSION_TTL")).minutes
    end
  end
end
