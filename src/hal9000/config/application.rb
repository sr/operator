require File.expand_path("../boot", __FILE__)

require "json"
require "active_support/core_ext/class/subclasses"
require "active_support/string_inquirer"

if ENV["RAILS_ENV"] == "test"
  Bundler.require(:default, :test)
else
  Bundler.require(:default)
end

require "lita/cli"
require "hal9000"
require "hal9000/lita_help"

module HAL9000
  def self.env
    ActiveSupport::StringInquirer.new(ENV["HAL9000_ENV"] || "development")
  end

  class Application
    def self.configure
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

        config.robot.adapter = ENV.fetch("LITA_ADAPTER", "shell").to_sym

        if config.adapters.respond_to?(:bread)
          config.adapters.bread.token = ENV.fetch("HIPCHAT_TOKEN", "")
          config.adapters.bread.server = ENV.fetch("HIPCHAT_SERVER", "https://hipchat.dev.pardot.com")
          config.adapters.bread.address = "0.0.0.0:#{ENV.fetch("HAL9000_GRPC_PORT", "9001")}"
        end

        config.http.host = ENV.fetch("HAL9000_HTTP_HOST", "0.0.0.0")
        config.http.port = Integer(ENV.fetch("HAL9000_HTTP_PORT", 8080))

        ## Example: Set options for the chosen adapter.
        # config.adapter.username = "myname"
        # config.adapter.password = "secret"
        if config.adapters.respond_to?(:hipchat)
          config.adapters.hipchat.server = ENV.fetch("HIPCHAT_SERVER", "hipchat.dev.pardot.com")
          config.adapters.hipchat.jid = ENV.fetch("HIPCHAT_JID", "1_342@chat.btf.hipchat.com")
          config.adapters.hipchat.muc_domain = ENV.fetch("HIPCHAT_MUC_DOMAIN", "conf.btf.hipchat.com")
          config.adapters.hipchat.password = ENV.fetch("HIPCHAT_PASSWORD", "")
          config.adapters.hipchat.rooms = [
            "1_build__automate@conf.btf.hipchat.com",
            "1_bread_privileged@conf.btf.hipchat.com",
            "1_opsbros@conf.btf.hipchat.com",
            "1_ops@conf.btf.hipchat.com",
            "1_project_terminus@conf.btf.hipchat.com",
            "1_engineering@conf.btf.hipchat.com",
            "1_bottest@conf.btf.hipchat.com"
          ]
          config.adapters.hipchat.debug = true
        end

        # Replication fixing
        config.handlers.replication_fixing_handler.pagerduty_service_key = ENV.fetch("REPFIX_PAGERDUTY_SERVICE_KEY", "")

        # Setup Zabbix handler
        if config.handlers.respond_to?(:zabbix_handler)
          config.handlers.zabbix_handler.pagerduty_service_key = ENV.fetch("ZABBIX_PAGERDUTY_SERVICE_KEY", "")
          config.handlers.zabbix_handler.status_room = ENV.fetch("ZABBIX_STATUS_ROOM", "1_ops@conf.btf.hipchat.com")
          config.handlers.zabbix_handler.zabbix_user = ENV.fetch("ZABBIX_USER", "")
          config.handlers.zabbix_handler.zabbix_password = ENV.fetch("ZABBIX_PASSWORD", "")
          config.handlers.zabbix_handler.monitor_hipchat_notify = true
          config.handlers.zabbix_handler.monitor_interval_seconds = 60
          config.handlers.zabbix_handler.monitor_retries = 5
          config.handlers.zabbix_handler.monitor_retry_interval_seconds = 5
          config.handlers.zabbix_handler.monitor_http_timeout_seconds = 30
        end

        if config.handlers.respond_to?(:emergency_escalation_handler)
          config.handlers.emergency_escalation_handler.pagerduty_service_key = ENV.fetch("SRE_PAGERDUTY_SERVICE_KEY", "")
        end

        ## Example: Set options for the Redis connection.
        config.redis[:host] = ENV.fetch("REDIS_HOST", "127.0.0.1")
        config.redis[:port] = ENV.fetch("REDIS_PORT", "6379").to_i

        ## Example: Set configuration for any loaded handlers. See the handler's
        ## documentation for options.
        # config.handlers.some_handler.some_config_key = "value"
      end
    end

    def self.load_all
      app_dir = Pathname(__FILE__).dirname.join("../app").expand_path

      $LOAD_PATH.unshift(app_dir.join("models").to_s)

      Pathname.glob("#{app_dir}/models/**/*.rb").each do |file|
        require file.sub(".rb", "")
      end

      require app_dir.join("handlers", "application_handler")

      Pathname.glob("#{app_dir}/handlers/*_handler.rb").each do |file|
        if file.basename.to_s == "application_handler.rb"
          next
        end

        if file.basename.to_s == "zabbix_handler.rb" && HAL9000.env.development?
          next
        end

        require file.sub(".rb", "")
      end

      ApplicationHandler.subclasses.each do |handler|
        Lita.register_handler(handler)
      end
    end

    def self.start
      $stderr.puts "HAL9000 starting in #{HAL9000.env}..."
      Lita::CLI.start
    end
  end
end
