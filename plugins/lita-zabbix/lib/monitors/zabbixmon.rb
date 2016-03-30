require 'securerandom'

module Monitors
  class Zabbixmon

    config :test_api_endpoint, default: 'cgi-bin/zabbix-server-check.sh'
    #TODO: how does the friendly hostname work in regards to the ugly hostnamed 1-1 and 1-2 servers, and how will it work w/ the data insertion script/api?
    config :check_hosts, default: ['pardot0-monitor1-1-datacenter.ops.sfdc.net']
    config :item, default: 'system:general'
    config :key, default: 'zabbix_status'
    config :retries, default: 5
    config :retry_interval_seconds, default: 5
    config :payload_length, default: 10
    config :hipchat_notify, default: false
    config :status_room, default: "1_ops@conf.btf.hipchat.com"

    MONITOR_NAME = "zabbixmon"
    ERR_NON_200_HTTP_CODE = "Zabbix Host Failed to Respond to an HTTP request with the appropriate status code (! HTTP 200)"

    def initialize(datacenters:, redis:, clients:, log:)
      @datacenters = datacenters
      @redis = redis
      @clients = clients
      @log = log
      @failures = []
    end


    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor(zbx_host:, zbx_username:, zbx_password:)

      # cycle through datacenters
      datacenters.each do |datacenter|

        retry_attmept_iterator=0
        # make a one time use random string to insert and detect
        payload = SecureRandom.random_number(36**config.payload_length).to_s(36).rjust(config.payload_length, '0')
        url="https://#{zbx_host}/#{config.test_api_endpoint}?#{payload}"

        # deliver the test payload
        payload_delivery_response=deliver_zabbixmon_payload(url, zbx_username, zbx_password)

        # parse the test payload
        payload_delivery_response.code == '200' ? @log.debug("Monitor Payload Delivered Successfully") : @failures['datacenter'] = "ZabbixMon[#{datacenter}].payload_delivery_response.code : #{ERR_NON_200_HTTP_CODE}"

        # client call: insert data via api endpoint
        @clients[datacenter].deliver_zabbixmon_payload(url, zbx_username, zbx_password)

        while retry_attempt_iterator < config.retries && @failures['datacenter'].nil? do

          #TODO: do I need to loop through config.check_hosts (1-1 and 1-2) here?

            ## grab host data for "check host"
            ## if this fails then
            #@failures.push({ datacenter: datacenter, err: ERR_SERVICE_NOT_RESPONDING})

            ## check for existence of config.key
            #if this fails then
            #@failures.push({ datacenter: datacenter, err: })

            ## check if VALUE = payload
            #@failures.push({ datacenter: datacenter, err: ERR_SERVICE_NOT_RESPONDING})

            ## if (key.exists? and value != expected value) or (if 5th loop)


          sleep config.retry_interval_seconds
          retry_attempt_iterator+=1
        end

      end

    end


    def monitor_name()
      MONITOR_NAME
    end

    private
    def deliver_zabbixmon_payload(url:, user:, password:)
      # example: https://zabbix-dfw.pardot.com/cgi-bin/zabbix-server-check.sh?<date-or-other-thing-you-want-here>
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      req.basic_auth user, password
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
    end
  end
end

