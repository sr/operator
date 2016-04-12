require_relative "lib/lita/adapters/nothing"

Lita.configure do |config|
  config.robot.name = "HAL9000"
  config.robot.alias = "!"
  config.robot.locale = :en

  # The severity of messages to log. Options are:
  # :debug, :info, :warn, :error, :fatal
  # Messages at the selected level and above will be logged.
  config.robot.log_level = :debug

  # An array of user IDs that are considered administrators. These users
  # the ability to add and remove other users from authorization groups.
  # What is considered a user ID will change depending on which adapter you use.
  config.robot.admins = [
    "1_104@chat.btf.hipchat.com", # Jan Ulrich
    "1_261@chat.btf.hipchat.com", # Rory Kiefer
    "1_282@chat.btf.hipchat.com", # Andy Lindeman
    "1_350@chat.btf.hipchat.com", # Simon Rozet
  ]

  config.robot.adapter = (ENV.fetch("LITA_ADAPTER", "shell")).to_sym

  config.http.host = "0.0.0.0"
  config.http.port = 8080

  ## Example: Set options for the chosen adapter.
  # config.adapter.username = "myname"
  # config.adapter.password = "secret"
  config.adapters.hipchat.server = ENV.fetch("HIPCHAT_SERVER", "hipchat.dev.pardot.com")
  config.adapters.hipchat.jid = ENV.fetch("HIPCHAT_JID", "1_342@chat.btf.hipchat.com")
  config.adapters.hipchat.muc_domain = ENV.fetch("HIPCHAT_MUC_DOMAIN", "conf.btf.hipchat.com")
  config.adapters.hipchat.password = ENV.fetch("HIPCHAT_PASSWORD", "")
  config.adapters.hipchat.debug = true

  # Replication fixing
  config.handlers.replication_fixing.pagerduty_service_key = ENV.fetch("PAGERDUTY_SERVICE_KEY", "")

  # Set the Hipchat Chatroom
  config.handlers.zabbix.status_room = "1_ops@conf.btf.hipchat.com"

  # Set the datacenters
  #config.handlers.zabbix.datacenters = ['dfw','phx']

  # Zabbix Setup
  config.handlers.zabbix.zabbix_user = ENV.fetch("ZABBIX_USER", "")
  config.handlers.zabbix.zabbix_password = ENV.fetch("ZABBIX_PASSWORD", "")

  # Zabbix Monitor Config
  config.handlers.zabbix.monitor_hipchat_notify = false
  config.handlers.zabbix.monitor_interval_seconds = 60
  config.handlers.zabbix.monitor_retries = 5
  config.handlers.zabbix.monitor_retry_interval_seconds = 5
  config.handlers.zabbix.monitor_http_read_timeout_seconds =  30

  ## Example: Set options for the Redis connection.
  config.redis[:host] = ENV.fetch("REDIS_HOST", "127.0.0.1")
  config.redis[:port] = ENV.fetch("REDIS_PORT", "6379").to_i

  ## Example: Set configuration for any loaded handlers. See the handler's
  ## documentation for options.
  # config.handlers.some_handler.some_config_key = "value"
end
