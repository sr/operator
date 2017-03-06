sentry_dsn = ENV["EXPLORER_SENTRY_DSN"]
if sentry_dsn.present?
  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.environments = ["production"]
    config.proxy = ENV["https_proxy"]
  end
end
