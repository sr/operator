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
        begin
          Integer(User.count)
        rescue => e
          Instrumentation.log_exception(e)
          raise
        end
      end
    end

    initializer "explorer_app" do
      config.x.datacenter = ENV.fetch("EXPLORER_DATACENTER")
      config.x.restricted_access_ldap_group = "explorer-support"
      config.x.full_access_ldap_group = "explorer-full"
      config.x.support_role = 9
      config.x.session_ttl = Integer(ENV.fetch("EXPLORER_SESSION_TTL")).minutes
      config.x.rate_limit_period = Integer(ENV.fetch("EXPLORER_RATE_LIMIT_PERIOD")).minutes
      config.x.rate_limit_max = Integer(ENV.fetch("EXPLORER_RATE_LIMIT_MAX"))
      config.x.build_version = begin
        File.readlines("build.version").first
      rescue Errno::ENOENT
        if !Rails.env.development?
          Instrumentation.log_exception($!)
        end
        ""
      end
    end
  end
end
