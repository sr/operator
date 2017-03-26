require File.expand_path("../boot", __FILE__)
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "pinglish"
require "instrumentation"
require "salesforce_authenticator_api"

require "canoe_config"
require "canoe/ldap_authorizer"
require "canoe"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Canoe
  cattr_accessor :config do
    CanoeConfig.new(ENV.to_hash)
  end

  cattr_accessor :salesforce_authenticator do
    SalesforceAuthenticatorAPI.new(
      Canoe.config.salesforce_authenticator_consumer_id,
      Canoe.config.salesforce_authenticator_consumer_key
    )
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Eastern Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Disable automatic factory generation
    config.generators do |g|
      g.factory_girl false
    end

    # Autoload files from lib/
    config.autoload_paths << Rails.root.join("lib")

    # Similar to how ActiveRecord rescues ActiveRecord::NotFound to render 404,
    # do the same for Octokit::NotFound.
    config.action_dispatch.rescue_responses["Octokit::NotFound"] = :not_found

    config.colorize_logging = false

    config.middleware.use Rack::Attack
    config.middleware.use Pinglish do |ping|
      ping.check :db do
        begin
          Integer(Project.count)
        rescue => e
          Instrumentation.log_exception(e)
          raise
        end
      end
    end
  end
end
