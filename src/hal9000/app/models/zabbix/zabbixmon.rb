require "securerandom"

module Zabbix
  class Zabbixmon
    MONITOR_NAME = "zabbixmon".freeze
    MONITOR_SHORTHAND = "zbxmon".freeze
    INCIDENT_KEY = "#{MONITOR_NAME}-%s".freeze
    ERR_NON_200_HTTP_CODE = "HAL9000 HTTP'd Zabbix, but the host failed to respond to an HTTP request with the appropriate status code (! HTTP 200)".freeze
    ERR_ZBX_CLIENT_EXCEPTION = "HAL9000 attempted to use the ZabbixApi client, but an exception was thrown/handled: exception".freeze
    ZABBIX_ITEM_NOT_FOUND = "HAL9000 failed to find the payload via the API".freeze
    ZBXMON_KEY = "Zabbix_status".freeze
    ZBXMON_PAYLOAD_LENGTH = 20

    def initialize(redis:, zbx_client:, log:, zbx_username:, zbx_password:, datacenter:)
      @redis = redis
      @client = zbx_client
      @log = log
      @zbx_username = zbx_username
      @zbx_password = zbx_password
      @datacenter = datacenter
      @hard_failure = nil
      @soft_failures = Set.new([]) # soft-fails can used to provide feedback for hard-fail
    end

    attr_accessor :hard_failure

    # assumes not paused (pausing handled by supervisor and handler and prevents this call)
    def monitor(url, num_retries = 5, retry_interval_seconds = 5, timeout_seconds = 30)
      retry_attempt_iterator = 0
      retry_sz = "attempt #{(retry_attempt_iterator + 1)} / #{num_retries}"
      payload = SecureRandom.urlsafe_base64(ZBXMON_PAYLOAD_LENGTH).to_s # make a per-use random string
      monitor_success = false
      insert_payload(payload, url, timeout_seconds)

      while (retry_attempt_iterator < num_retries) && @hard_failure.nil? && !monitor_success
        # the state reported back from this loop is important! soft_fail = keep trying; hard_fail = stop and notify
        sleep retry_interval_seconds
        @log.debug("[#{monitor_name}] searching for #{payload} via API...")
        monitor_success = retrieve_payload(payload)
        @log.warn("[#{monitor_name}] FAILED to find an item that contains #{payload} from the zabbix (#{retry_sz})") unless monitor_success
        retry_attempt_iterator += 1
        retry_sz = "attempt #{retry_attempt_iterator} / #{num_retries}"
      end

      if monitor_success
        @log.debug("[#{monitor_name}] successfully retrieved payload (#{retry_sz})")
        @hard_failure = nil
      else
        @hard_failure ||= @soft_failures.to_a.join("; ")
        @log.error("[#{monitor_name}] has hard failed: #{@hard_failure}")
      end
    end

    def monitor_name
      MONITOR_NAME
    end

    private

    def insert_payload(payload, url, timeout_seconds)
      @log.debug("[#{monitor_name}] value generated: #{payload}")
      begin
        payload_delivery_response = deliver_zabbixmon_payload("#{url}#{payload}", timeout_seconds)
      rescue => e
        e = scrub_password(e)
        log.error("Error creating Zabbix maintenance supervisor for #{datacenter}: #{e}")
        err = "Payload Delivery completely failed and was 'rescued.' Error: #{e}."
        @hard_failure = "ZabbixMon[#{@datacenter}] payload insertion failed! #{ERR_NON_200_HTTP_CODE}\n#{e}"
        @log.error("[#{monitor_name}] ZabbixMon[#{@datacenter}] payload insertion failed: #{e} !")
      end

      if !payload_delivery_response.nil?
        if payload_delivery_response.code =~ /20./
          @log.debug("[#{monitor_name}] Monitor Payload Delivered Successfully")
        else
          err = scrub_password("#{payload_delivery_response.code} : #{payload_delivery_response.body}")
          @hard_failure ||= "ZabbixMon[#{@datacenter}] payload insertion failed! #{ERR_NON_200_HTTP_CODE}\n#{err}"
          @log.error("[#{monitor_name}] ZabbixMon[#{@datacenter}] payload insertion failed! #{err} ")
        end
      else
        @hard_failure ||= "Generic Payload Insertion Failure."
        @log.error("[#{monitor_name}] ZabbixMon[#{@datacenter}] #{@hard_failure}")
      end
    end

    def retrieve_payload(payload)
      begin
        success = false
        zbx_items = @client.get_item_by_name_and_lastvalue(ZBXMON_KEY, payload)
      rescue => e
        e = scrub_password(e)
        @log.error("[#{monitor_name}] #{ERR_ZBX_CLIENT_EXCEPTION}".gsub("%exception%", e))
        @soft_failures.add(ERR_ZBX_CLIENT_EXCEPTION.to_s.gsub("%exception%", e))
      end
      if zbx_items
        if !zbx_items.empty? # success case
          @log.debug("[#{monitor_name}] successfully observed #{payload} from Zabbix-#{@datacenter}")
          success = true
        else # fail case
          @soft_failures.add(ZABBIX_ITEM_NOT_FOUND.to_s)
        end
      else # fail case
        @soft_failures.add(ZABBIX_ITEM_NOT_FOUND.to_s)
      end
      @log.error("[#{monitor_name}] zbx_items=#{zbx_items}") unless success
      success
    end

    def deliver_zabbixmon_payload(url, timeout_seconds = 30)
      @log.debug("[#{monitor_name}] deliver_zabbixmon_payload url = #{url}")
      uri = URI url
      unless ENV["HAL9000_HTTP_PROXY"].nil?
        @proxy_uri = URI.parse(ENV["HAL9000_HTTP_PROXY"])
        @proxy_host = @proxy_uri.host
        @proxy_port = @proxy_uri.port
        @proxy_user, @proxy_pass = @proxy_uri.userinfo.split(/:/) if @proxy_uri.userinfo
      end

      http = Net::HTTP.new(uri.host, uri.port) if @proxy_uri.nil?
      http = Net::HTTP.Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass).new(uri.host, uri.port) unless @proxy_uri.nil?

      if uri.scheme == "https"
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_NONE # uncomment to not-verify https
      end

      http.read_timeout = timeout_seconds.to_i
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth @zbx_username, @zbx_password if @zbx_username
      response = http.request(request)

    rescue Timeout::Error
      @log.error("[#{monitor_name}] HTTP TIMEOUT while attempting to insert payload")
    rescue ::Lita::Handlers::Zabbix::MonitorDataInsertionFailed
      @log.error("[#{monitor_name}] has hard failed: ::Lita::Handlers::Zabbix::MonitorDataInsertionFailed")
    end
  end

  def scrub_password(str)
      str.gsub(@zabbix_password, "****") unless @zabbix_password.empty?
  end
end
