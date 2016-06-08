Rails.application.configure do
  # Allow web-console within Docker.
  config.web_console.whitelisted_ips = "10.0.2.0/24"

  # Temporary workaround for file loading not working correctly in a container.
  config.reload_classes_only_on_change = false

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
end
