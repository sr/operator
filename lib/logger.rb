require "syslog"

module Logger
  extend self

  PRIORITIES = {
    debug: Syslog::LOG_DEBUG,
    info: Syslog::LOG_INFO,
    notice: Syslog::LOG_NOTICE,
    warn: Syslog::LOG_WARNING,
    warning: Syslog::LOG_WARNING,
    alert: Syslog::LOG_ALERT,
    err: Syslog::LOG_ERR,
    error: Syslog::LOG_ERR,
    crit: Syslog::LOG_CRIT,
  }.freeze

  def log(our_priority, message)
    puts "[%s] %s" % [our_priority, message] unless ENV['CRON']

    Syslog.open do
      Syslog.log(PRIORITIES.fetch(our_priority), message)
    end
  end
end
