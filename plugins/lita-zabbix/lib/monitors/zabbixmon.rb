module Monitors
  class Zabbixmon

    config.handlers.zabbix.monitors.zabbixmon.monitor.endpoint.initial = 'cgi-bin/zabbix-server-check.sh'
    config.handlers.zabbix.monitors.zabbixmon.monitor.endpoint.final = '?'
    config.handlers.zabbix.monitors.zabbixmon.monitor.host = 'pardot0-monitor1-1-dfw.ops.sfdc.net'
    config.handlers.zabbix.monitors.zabbixmon.monitor.item = 'system:general'
    config.handlers.zabbix.monitors.zabbixmon.monitor.key = 'zabbix_status'

    MONITOR_NAME = "zabbixmon"

    def initialize()

      # typical variable setup ensemble
      # initialize client?

    end

    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor()

      # set up unique, 1-time-use 'value' to insert/read-back

      # cycle through datacenters
      ### client call: insert data via api endpoint
      ### loop 5 times
      ###### sleep 5
      ###### client call: grab host data for
      ###### check for existence of KEY
      ###### check for existence of VALUE

      ###### if (key.exists? and value != expected value) or (if 5th loop)
      ######### hard_fails["datacenter"]++

      # cycle through datacenters
      ### hard_fails["datacenter"] && report_failure("datacenter")

    end

    def report_failure

      # tell hipchat status_room
      # ping pagerduty

    end

    def monitor_name()
      MONITOR_NAME
    end

  end
end

