require 'securerandom'

module Zabbix
  class Zabbixmon

    MONITOR_NAME = "zabbixmon"
    MONITOR_SHORTHAND = "zbxmon"
    INCIDENT_KEY = "#{MONITOR_NAME}-%datacenter%"
    ERR_NON_200_HTTP_CODE = "HAL9000 HTTP'd Zabbix, but the host failed to respond to an HTTP request with the appropriate status code (! HTTP 200)"
    ERR_ZBX_CLIENT_EXCEPTION = "HAL9000 attempted to use the ZabbixApi client, but an exception was thrown/handled: exception"
    ZABBIX_ITEM_NOT_FOUND = "HAL9000 searched for an iteam w/ a particluar key and value, but did not find it. This is bad."
    ZBXMON_TEST_API_ENDPOINT = 'cgi-bin/zabbix-server-check.sh'
    ZBXMON_ITEM = 'system:general'
    ZBXMON_KEY = 'zabbix_status'
    ZBXMON_PAYLOAD_LENGTH = 10

    def initialize(redis:, clients:, log:)
      @redis = redis
      @clients = clients
      @log = log
    end


    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor(zbx_host, zbx_username, zbx_password, datacenter, payload_length, num_retries, retry_interval_seconds, timeout_seconds)
      retry_attmept_iterator=0
      retry_sz="retry attempt #{(retry_attmept_iterator + 1)} / #{num_retries}" # human readable retry counter
      
      # make a one time use random string to insert and detect
      payload = "#{SecureRandom.urlsafe_base64(payload_length)}"
      @log.info("[#{monitor_name}] value generated: #{payload}")
      
      # generate url w/ url payload
      url="https://#{zbx_host}/#{ZBXMON_TEST_API_ENDPOINT}?#{payload}"

      # deliver the test payload
      payload_delivery_response=deliver_zabbixmon_payload(url, zbx_username, zbx_password, timeout_seconds)

      # parse the test payload response
      if payload_delivery_response.code == '200'
        @log.debug("[#{monitor_name}] Monitor Payload Delivered Successfully")
      else
        # hard fail! :(
        @hard_failure = "ZabbixMon[#{datacenter}].payload_delivery_response.code : #{ERR_NON_200_HTTP_CODE}"
      end


      soft_failures = [] # track soft-fail state - used to provide feedback on hard-fail
      monitor_success = false # if true then "we did it, reddit!"
      while retry_attempt_iterator < num_retries && @hard_failure.nil? && !monitor_success do
        # try num_retries number of times, retry_interval_seconds seconds between each try, then pass/fail after this loop

        # delay before (re)trying
        sleep retry_interval_seconds

        # the state reported back from this loop is important! soft_fail = keep trying; hard_fail = hard stop and notify
        # do not overwrite a !200 w/ something above it on the app stack, like 'cant find key' for example

        begin
          # pull the "item" that contains the desired K/V pair
          system_general = @clients['datacenter'].get_item_by_key_and_lastvalue(ZBXMON_KEY, payload)
          @log.debug("[#{monitor_name}] zabbix client 'got_item' successfully")
        rescue => e
          @log.error("[#{monitor_name}] #{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e))
          soft_failures.push(
            "#{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e)
          ) unless soft_failures.include? "#{ERR_ZBX_CLIENT_EXCEPTION}".gsub('%exception%', e)
        end


        if system_general.result.length > 0
          # we found the key
           @log.info("[#{monitor_name}] successfully observed #{ZBXMON_KEY} : #{payload} from #{zbx_host} (#{retry_sz})")
            monitor_success = true
        else
          #we did not find the item
          @log.warn("[#{monitor_name}] 'observed key' FAILED : #{ZBXMON_KEY} (#{retry_sz})")
          soft_failures.push(
              "#{ZABBIX_ITEM_NOT_FOUND}"
          ) unless soft_failures.include? "#{ZABBIX_ITEM_NOT_FOUND}"
        end

        retry_attempt_iterator+=1
      end

      # work is done! Establish pass/fail here
      if monitor_success
        # we did it, reddit!
        @log.info("[#{monitor_name}] 's work is done here. There is no issue to report. (successkid)")
        # wipe fails; they dont matter
        @hard_failure = nil
        soft_failures = []
      else
        # (okay)(feelsbadman)
        @hard_failure ||= soft_failures.join('; ')
        # scenario: data insertion failed and the read process never started
        @log.error("[#{monitor_name}] has hard failed: #{@hard_failure} ")
      end
    end

    def monitor_name
      MONITOR_NAME
    end

    private
    def deliver_zabbixmon_payload(url:, user:, password:, timeout_seconds:)
      # example: https://zabbix-dfw.pardot.com/cgi-bin/zabbix-server-check.sh?<date-or-other-thing-you-want-here>
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      req.basic_auth user, password
      res = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => timeout_seconds) {|http|
        http.request(req)
      }
    rescue ::Lita::Handlers::Zabbix::MonitorDataInsertionFailed
      @log.error("[#{monitor_name}] has hard failed: #{@hard_failure} ")
    end
  end
end