require 'securerandom'

module Monitors
  class Zabbixmon

    config :test_api_endpoint, default: 'cgi-bin/zabbix-server-check.sh'
    #TODO: how does the friendly hostname work in regards to the ugly hostnamed 1-1 and 1-2 servers, and how will it work w/ the data insertion script/api?
    config :check_hosts, default: ['pardot0-monitor1-1-[DATACENTER].ops.sfdc.net', 'pardot0-monitor1-2-[DATACENTER].ops.sfdc.net']
    config :item, default: 'system:general'
    config :key, default: 'zabbix_status'
    config :retries, default: 5
    config :retry_interval_seconds, default: 5
    config :payload_length, default: 10

    MONITOR_NAME = "zabbixmon"
    ERR_SERVICE_NOT_RESPONDING = "Zabbix Host Failed to Respond to an HTTP request (request time out)"
    ERR_NON_200_HTTP_CODE = "Zabbix Host Failed to Respond to an HTTP request with the appropriate status code (! HTTP 200)"

    def initialize(datacenters:, redis:, client:, log:)
      @datacenters = datacenters
      @redis = redis
      @client = client
      @log = log
      @failures = []
    end


    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor()

      # set up unique, 1-time-use 'value' to insert/read-back

      # cycle through datacenters
      datacenters.each do |datacenter|

        retry_attmept_iterator=0
        initial_fail_length = @failures.length
        payload = test_payload.to_s

        # client call: insert data via api endpoint
        client[datacenter].insert_test_payload(payload)

        while retry_attempt_iterator < config.retries || @failures.length != initial_fail_length do


          #TODO: do I need to loop through config.check_hosts (1-1 and 1-2) here?

          ## grab host data for "check host"
          ## if this fails then
          #@failures.push({ datacenter: datacenter, err: ERR_SERVICE_NOT_RESPONDING})

          ## check for existence of config.key
          #if this fails then
          #@failures.push({ datacenter: datacenter, err: ERR_SERVICE_NOT_RESPONDING})

          ## check if VALUE = payload

          ## if (key.exists? and value != expected value) or (if 5th loop)


          sleep config.retry_interval_seconds
          retry_attempt_iterator+=1
        end

      end

    end



    def monitor_name()
      MONITOR_NAME
    end

    def test_payload
      SecureRandom.random_number(36**config.payload_length).to_s(36).rjust(config.payload_length, '0')
    end

  end
end

