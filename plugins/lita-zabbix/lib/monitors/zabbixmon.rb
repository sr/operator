require "set"

module Monitors
  class Zabbixmon

    config.handlers.zabbix.monitors.zabbixmon.monitor.item = 'system:general'
    config.handlers.zabbix.monitors.zabbixmon.monitor.key = 'zabbix_status'

    MONITOR_NAME = "zabbixmon"

    def initialize()


    end

    def monitor_name()
      MONITOR_NAME
    end
  end
end

