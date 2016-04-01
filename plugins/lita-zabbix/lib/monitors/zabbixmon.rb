require 'securerandom'

module Monitors
  class Zabbixmon

    config :test_api_endpoint, default: 'cgi-bin/zabbix-server-check.sh'
    #TODO: how does the friendly hostname work in regards to the ugly hostnamed 1-1 and 1-2 servers, and how will it work w/ the data insertion script/api?
    config :item, default: 'system:general'
    config :key, default: 'zabbix_status'
    config :retries, default: 5
    config :retry_interval_seconds, default: 5
    config :payload_length, default: 10
    config :hipchat_notify, default: false
    config :status_room, default: "1_ops@conf.btf.hipchat.com"
    config :http_read_timeout, default: 30

    MONITOR_NAME = "zabbixmon"
    ERR_NON_200_HTTP_CODE = "[HAL9000 HTTP'd Zabbix, but the host failed to respond to an HTTP request with the appropriate status code (! HTTP 200)"
    ERR_ZBX_CLIENT_EXCEPTION = "HAL9000 attempted to use the ZabbixApi client, but an exception was thrown/handled: exception"
    ERR_ZABBIX_STATUS_KEY_MISSING = "HAL9000 was able to load the system:general 'item' but was unable to locate the key zabbix_status 'key' "
    ERR_VALUE_MISMATCH = "HAL9000 was able to load system:general/zabbix_status, but the value it expected was not the one received."

    def initialize(datacenters:, redis:, clients:, log:)
      @datacenters = datacenters
      @redis = redis
      @clients = clients
      @log = log
      @hard_failures = []
    end


    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor(zbx_host:, zbx_username:, zbx_password:)

      # cycle through datacenters
      datacenters.each do |datacenter|

        retry_attmept_iterator=0
        # make a one time use random string to insert and detect
        payload = SecureRandom.random_number(36**config.payload_length).to_s(36).rjust(config.payload_length, '0')
        @log.info("[#{monitor_name}] value generated: #{payload}")
        url="https://#{zbx_host}/#{config.test_api_endpoint}?#{payload}"

        # deliver the test payload
        payload_delivery_response=deliver_zabbixmon_payload(url, zbx_username, zbx_password)

        # parse the test payload response
        if payload_delivery_response.code == '200'
          @log.debug("[#{monitor_name}] Monitor Payload Delivered Successfully")
        else
          # hard fail! :(
          @hard_failures['datacenter'] = "ZabbixMon[#{datacenter}].payload_delivery_response.code : #{ERR_NON_200_HTTP_CODE}"
        end


        soft_failures = [] # track soft-fail state - used to provide feedback on hard-fail
        monitor_success = false # if true then "we did it, reddit!"
        while retry_attempt_iterator < config.retries && @hard_failures['datacenter'].nil? && !monitor_success do
          # try config.retries number of times, config.retry_interval seconds between each try, then pass/fail after this loop

          # delay before (re)trying
          sleep config.retry_interval_seconds

          # human readable retry counter for logging purposes
          retry_sz="retry attempt #{(retry_attmept_iterator + 1)} / #{config.retries}"

          # the state reported back from this loop is important! soft_fail = keep trying; hard_fail = hard stop and notify
          # do not overwrite a !200 w/ something above it on the app stack, like 'cant find key' for example

          begin
            # pull the "item" that contains the desired K/V pair
            system_general = @clients['datacenter'].get_item_by_lastvalue(payload)
            @log.debug("[#{monitor_name}] zabbix client 'got_item' successfully")
          rescue => e
            @log.error("[#{monitor_name}] #{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e))
            soft_failures.push("#{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e)) unless soft_failures.include? "#{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e)
          end


          if system_general.keys.contains(config.key)
            # we found the key
            @log.debug("[#{monitor_name}] 'observed key' successfully: #{config.key} (#{retry_sz})")
            
            if payload == system_general[config.key]
              # we found the value
              @log.info("[#{monitor_name}] 'observed value' successfully: #{system_general[config.key]} (#{retry_sz})")
              monitor_success = true
            else
              # we did not find the value :(
              @log.warn("[#{monitor_name}] 'observed value' FAILED : #{system_general[config.key]} (#{retry_sz})")
              soft_failures.push("#{ERR_VALUE_MISMATCH}") unless soft_failures.include? "#{ERR_VALUE_MISMATCH}"
            end

          else
            #we did not find the key :(
            @log.warn("[#{monitor_name}] 'observed key' FAILED : #{config.key} (#{retry_sz})")
            soft_failures.push("#{ERR_ZABBIX_STATUS_KEY_MISSING}") unless soft_failures.include? "#{ERR_ZABBIX_STATUS_KEY_MISSING}"
          end

          retry_attempt_iterator+=1
        end

        # work is done! Establish pass/fail here
        if monitor_success
          # we did it, reddit!

          @log.info("[#{monitor_name}] 's work is done here'(successkid)")
          # wipe fails; they dont matter
          @hard_failures = []
          soft_failures = []

        else
          # (okay)(feelsbadman)

          # scenario: insertion returned 200, but we did not find the right value
          if @hard_failures['datacenter'].nil?
            # WHAT HAPPEN? WE GET SIGNAL. MAIN SCREEN TURN ON.
            @hard_failures['datacenter'] = soft_failures.join('; ')
          # scenario: data insertion failed and the read process never started
          end
          # collect errors
          @log.error("[#{monitor_name}] has hard failed: #{@hard_failures['datacenter']} ")
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
      res = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => config.http_read_timeout) {|http|
        http.request(req)
      }
    end
  end
end