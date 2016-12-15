require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

require_relative "../lib/changeling_config"

require_relative "../lib/metrics"
require_relative "../lib/exceptions"
require_relative "../lib/stream/event"
require_relative "../lib/stream/processor"
require_relative "../lib/clients/heimdall"
require_relative "../lib/clients/github"
require_relative "../lib/notifiers/chat"
require_relative "../lib/multipass_monitor"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Changeling
  cattr_accessor :config do
    ChangelingConfig.new
  end

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      { request_id: event.payload[:request_id] }
    end

    config.autoload_paths += %W(#{config.root}/app)

    config.generators do |g|
      g.assets = false
      g.helper = false
      g.view_specs = false
    end

    config.active_job.queue_adapter = :sidekiq
  end
  cattr_accessor :config do
    ChangelingConfig.new
  end
end
