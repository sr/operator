require "zabbixapi"
require "zabbix/maintenance_supervisor"
require "zabbix/client"
require "zabbix/zabbixmon"
require "zabbix/monitor_supervisor"
require "zabbix/pagerduty_pager"
require "zabbix/test_pager"

class ZabbixHandler < ApplicationHandler
  template_root File.expand_path("../../templates/zabbix", __FILE__)

  module HumanTime
    def self.parse(str, now: Time.now)
      if /^([+-]?\d+)(w|wk|wks|week|weeks)$/i =~ str
        Time.now + Regexp.last_match(1).to_i * 60 * 60 * 24 * 7
      elsif /^([+-]?\d+)(d|day|day)$/i =~ str
        Time.now + Regexp.last_match(1).to_i * 60 * 60 * 24
      elsif /^([+-]?\d+)(h|hr|hrs|hour|hours)$/i =~ str
        Time.now + Regexp.last_match(1).to_i * 60 * 60
      elsif /^([+-]?\d+)(m|min|mins|minute|minutes)$/i =~ str
        Time.now + Regexp.last_match(1).to_i * 60
      elsif /^([+-]?\d+)(s|sec|secs|second|seconds)$/i =~ str
        Time.now + Regexp.last_match(1).to_i
      else
        Time.parse(str)
      end
    end
  end

  MonitorNotFound = Class.new(StandardError)
  MonitorDataInsertionFailed = Class.new(StandardError)
  MonitoringFailure = Class.new(StandardError)
  PagerFailed = Class.new(StandardError)
  MONITOR_FAIL_ERRMSG = "::Lita::Handlers::Zabbix::run_monitors has failed, triggering its rescue clause".freeze
  CHAT_ERRMSG = "Sorry, something went wrong.".freeze
  ZABBIX_CHEF_APP_NAME = "app:chef".freeze

  # config: zabbix
  config :zabbix_api_url, default: "https://zabbix-%datacenter%.pardot.com/api_jsonrpc.php"
  config :zabbix_monitor_payload_url, default: "https://zabbix-%datacenter%.pardot.com/cgi-bin/zabbix-status-check.sh?"
  config :zabbix_user, default: "Admin"
  config :zabbix_password, required: "changeme"

  # config: datacenters
  config :datacenters, default: %w[dfw phx]
  config :default_datacenter, default: "dfw"

  # config: hal9000's "home room"
  config :status_room, default: "1_ops@conf.btf.hipchat.com"

  # config: chef monitoring
  config :chef_monitor_interval_seconds, default: 3600

  # config: zabbix monitor
  config :monitor_hipchat_notify, default: false
  config :monitor_interval_seconds, default: 60
  config :monitor_retries, default: 5
  config :monitor_retry_interval_seconds, default: 5
  config :monitor_http_timeout_seconds, default: 30
  config :active_monitors, default: [::Zabbix::Zabbixmon::MONITOR_NAME]
  config :paging_monitors, default: [::Zabbix::Zabbixmon::MONITOR_NAME]

  # config: page-r-doodie
  config :pager, default: "pagerduty"
  config :pagerduty_service_key

  route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:start)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :start_maintenance, command: true, help: {
    "zabbix maintenance start HOST" => "Puts hosts matching HOST in maintenance mode for 1 hour",
    "zabbix maintenance start HOST until=24h" => "Puts hosts matching HOST in maintenance mode for 24 hours"
  }

  route /^zabbix(?:-(?<datacenter>\S+))?\s+maintenance\s+(?:stop)\s+(?<host>\S+)(?:\s+(?<options>.*))?$/i, :stop_maintenance, command: true, help: {
    "zabbix maintenance stop HOST" => "Brings hosts matching HOST out of maintenance mode"
  }

  route /^zabbix monitor (?<datacenter>\S+)\s+pause(?:\s+(?<options>.*))?$/i, :pause_monitor, command: true, help: {
    "zabbix monitor <datacenter> pause" => "Pauses the zabbix monitor for <datacenter> for 1 hour",
    "zabbix monitor <datacenter> pause until=24h" => "Pauses the zabbix monitor for <datacenter> for 24 hours"
  }

  route /^zabbix monitor (?<datacenter>\S+)\s+unpause(?:\s+(?<options>.*))?$/i, :unpause_monitor, command: true, help: {
    "zabbix monitor <datacenter> unpause" => "Unpauses <datacenter>s zabbix monitor"
  }

  route /^zabbix monitor run (?<datacenter>\S+)$/i, :manually_run_monitor, command: true, help: {
    "zabbix monitor run <datacenter>" => "runs a manual check on zabbix for a particular <datacenter>"
  }

  route /^zabbix monitor testpager$/i, :test_pager, command: true, help: {
    "zabbix monitor testpager" => "invokes a test page to pagerduty"
  }

  route /^zabbix monitor status$/i, :monitor_status, command: true, help: {
    "zabbix monitor status" => "Provides zabbix monitor status"
  }

  route /^zabbix monitor info$/i, :monitor_info, command: true, help: {
    "zabbix monitor info" => "Provides details on monitoring configuration"
  }

  route /^zabbix monitor (pause|unpause).*$/i, :invalid_zabbixmon_syntax, command: true

  on :connected, :start_monitoring

  def invalid_zabbixmon_syntax(response)
    response.reply_with_mention('Invalid syntax; try "zabbix monitor <datacenter> pause/unpause"')
  end

  def initialize(robot)
    super
    @pager = \
      case config.pager.to_s
      when "pagerduty"
        ::Zabbix::PagerdutyPager.new(config.pagerduty_service_key)
      when "test"
        ::Zabbix::TestPager.new
      else
        raise ArgumentError, "unknown pager type: #{config.pager}"
      end
    @clients = Hash.new { |h, k| h[k] = build_zabbix_client(datacenter: k) }
    config.datacenters.each do |datacenter|
      begin
        maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log)
        maintenance_supervisor.on_host_maintenance_expired = proc { |host| host_maintenance_expired(host) }
        maintenance_supervisor.ensure_supervising
      rescue => e
        log_error("Error creating Zabbix maintenance supervisor for #{datacenter}: #{e}")
      end

      begin
        monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log)
        monitor_supervisor.on_monitor_unpaused = proc { |monitor| monitor_expired(monitor) }
        monitor_supervisor.ensure_supervising
      rescue => e
        log_error "Error creating Zabbix monitor supervisor for #{datacenter}: #{e}"
      end
    end
    @status_room = ::Lita::Source.new(room: config.status_room)
  end

  on(:connected) do
    robot.join(config.status_room)
  end

  def monitor_status(response)
    msg = "\nMonitor / Status / Paging?"
    config.active_monitors.each do |active_monitor|
      config.datacenters.each do |datacenter|
        next unless active_monitor == ::Zabbix::Zabbixmon::MONITOR_NAME
        monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
          datacenter: datacenter,
          redis: redis,
          client: @clients[datacenter],
          log: log)
        status = monitor_supervisor.get_paused_monitors.include?(::Zabbix::Zabbixmon::MONITOR_NAME) ? "paused (failed)" : "active (successful)"
        paging = config.paging_monitors.include?(::Zabbix::Zabbixmon::MONITOR_NAME) ? "PAGER: #{config.pager}" : "NOT PAGING"
        msg += "\n#{::Zabbix::Zabbixmon::MONITOR_NAME}-#{datacenter}  / #{status} / #{paging}"
      end
    end
    response.reply_with_mention(msg.to_s)
  rescue => e
    response.reply_with_mention(CHAT_ERRMSG)
    log_error "Sorry, something went wrong: #{e}"
  end

  def monitor_info(response)
    msg = "Datacenters: #{config.datacenters.join(",")}"
    msg += "\nActive Monitors: #{config.active_monitors.join(",")}"
    msg += "\nPaging Monitors: #{config.paging_monitors.join(",")}"
    msg += "\nMonitor Hipchat-Notify: #{config.monitor_hipchat_notify}"
    msg += "\nMonitor Interval (seconds): #{config.monitor_interval_seconds}"
    msg += "\nRetries: #{config.monitor_retries}"
    msg += "\nRetry Interval: #{config.monitor_retry_interval_seconds}"
    msg += "\nRead Timeout: #{config.monitor_http_timeout_seconds}"
    response.reply_with_mention("Monitor Status:\n#{msg}")
  end

  def test_pager(response)
    response.reply_with_mention("Initiating paging routine.")
    monitor_fail_notify(
      ::Zabbix::Zabbixmon::MONITOR_NAME,
    "test",
    "This is a test of the ZabbixMon pager. Please dismiss and ignore.",
    true,
    true)
  end

  def start_maintenance(response)
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    validate_datacenter(datacenter: datacenter, response: response) || return

    host_glob = response.match_data["host"]
    hosts = @clients[datacenter].search_hosts(host_glob)
    options = parse_options(response.match_data["options"])

    until_time = \
      if options["until"]
        begin
          HumanTime.parse(options["until"])
        rescue ArgumentError
          response.reply_with_mention("Sorry, I couldn't parse this duration: #{options["until"]}")
        end
      else
        Time.now + 3600
      end

    maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
      datacenter: datacenter,
      redis: redis,
      client: @clients[datacenter],
      log: log,
    )

    hosts.each do |host|
      maintenance_supervisor.start_maintenance(
        host: host,
        until_time: until_time,
      )
    end

    if !hosts.empty?
      response.reply_with_mention("OK, I've started maintenance on #{host_glob} (matched #{hosts.length} hosts) until #{until_time}")
    else
      response.reply_with_mention("Sorry, no hosts matched #{host_glob}")
    end
  rescue => e
    response.reply_with_mention(CHAT_ERRMSG)
    log_error("Sorry, something went wrong: #{e}")
  end

  def pause_monitor(response)
    datacenter = response.match_data["datacenter"]
    response.reply("/me failed to parse a datacenter from your request. Defaulting to #{config.default_datacenter}") unless datacenter
    datacenter ||= config.default_datacenter
    validate_datacenter(datacenter: datacenter, response: response) || return
    options = parse_options(response.match_data["options"])

    until_time = \
      if options["until"]
        begin
          HumanTime.parse(options["until"])
        rescue ArgumentError
          response.reply_with_mention("Sorry, I couldn't parse this duration: #{options["until"]}")
        end
      else
        Time.now + 3600
      end

    monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
      datacenter: datacenter,
      redis: redis,
      client: @clients[datacenter],
      log: log)
    monitor_supervisor.pause_monitor(
      monitorname: ::Zabbix::Zabbixmon::MONITOR_NAME,
      until_time: until_time)

    response.reply_with_mention("OK, I've paused zabbixmon for the #{datacenter} datacenter until #{until_time}")
  rescue => e
    response.reply_with_mention(CHAT_ERRMSG)
    log_error("Sorry, something went wrong: #{e}")
  end

  def stop_maintenance(response)
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    validate_datacenter(datacenter: datacenter, response: response) || return

    host_glob = response.match_data["host"]
    hosts = @clients[datacenter].search_hosts(host_glob)

    maintenance_supervisor = ::Zabbix::MaintenanceSupervisor.get_or_create(
      datacenter: datacenter,
      redis: redis,
      client: @clients[datacenter],
      log: log)
    hosts.each do |host|
      maintenance_supervisor.stop_maintenance(
        host: host)
    end

    if !hosts.empty?
      response.reply_with_mention("OK, I've stopped maintenance on #{host_glob} (matched #{hosts.length} hosts)")
    else
      response.reply_with_mention("Sorry, no hosts matched #{host_glob}")
    end
  rescue => e
    response.reply_with_mention(CHAT_ERRMSG)
    log_error("Sorry, something went wrong: #{e}")
  end

  def unpause_monitor(response)
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    validate_datacenter(datacenter: datacenter, response: response) || return
    ::Zabbix::MonitorSupervisor.get_or_create(
      datacenter: datacenter,
      redis: redis,
      client: @clients[datacenter],
      log: log,
    ).unpause_monitor(monitorname: ::Zabbix::Zabbixmon::MONITOR_NAME)
    response.reply_with_mention("OK, I've unpaused zabbixmon for datacenter #{datacenter}. Monitoring will resume.")
  rescue => e
    response.reply_with_mention(CHAT_ERRMSG)
    log_error("Sorry, something went wrong: #{e}")
  end

  def host_maintenance_expired(hostname)
    robot.send_message(@status_room, "/me is bringing #{hostname} out of maintenance")
  end

  def monitor_expired(monitorname)
    robot.send_message(@status_room, "/me is unpausing #{monitorname} (warning)")
  end

  def manually_run_monitor(response)
    datacenter = response.match_data["datacenter"]
    response.reply("/me failed to parse a datacenter from your request") unless datacenter
    validate_datacenter(datacenter: datacenter, response: response) || return
    if datacenter
      success = run_monitor(datacenter)
      response.reply_with_mention("zabbix-#{datacenter} is confirmed alive") if success
      response.reply_with_mention("zabbix-#{datacenter} is dead, Jim") unless success
    end
  end

  def start_monitoring(_payload)
    every(config.monitor_interval_seconds) do |_timer|
      run_monitors
    end

    check_for_chef_problems
    every(config.chef_monitor_interval_seconds) do
      check_for_chef_problems
    end
  end

  def check_for_chef_problems
    @clients.each do |datacenter, client|
      begin
        problems = client.get_problem_triggers_by_app_name(ZABBIX_CHEF_APP_NAME)
        if problems && !problems.empty?
          robot.send_message(
            @status_root,
            render_template("chef_problems", datacenter: datacenter, problems: problems)
          )
        end
      rescue => e
        robot.send_message(@status_room, "Something went wrong when I tried to check for problems with Chef in #{datacenter}: #{e}")
      end
    end
  end

  def run_monitors
    # outer catch block: to keep things moving (handled)
    log.info("[lita-zabbix] executing run_monitors")
    config.datacenters.each do |datacenter|
      run_monitor(datacenter)
    end
  rescue ::Lita::Handlers::Zabbix::MonitoringFailure
    log.error("::Lita::Handlers::Zabbix::run_monitors has failed")
    monitor_fail_notify(::Zabbix::Zabbixmon::MONITOR_NAME,
      "[no-DC]",
      MONITOR_FAIL_ERRMSG,
      config.monitor_hipchat_notify,
      config.paging_monitors.include?(zabbixmon.monitor_name))
  end

  def run_monitor(datacenter)
    success = false
    begin # inner catch block: to be able to "see" what happened on failure (unhandled)
      monitor_supervisor = ::Zabbix::MonitorSupervisor.get_or_create(
        datacenter: datacenter,
        redis: redis,
        log: log,
        client: @clients[datacenter])
      log.debug("[lita-zabbix] monitor_supervisor: #{monitor_supervisor}")
      config.active_monitors.reject { |x| monitor_supervisor.get_paused_monitors.include? x }.each do |monitor|
        if monitor == ::Zabbix::Zabbixmon::MONITOR_NAME
          success = monitor_zabbix(datacenter)
        end
      end
    rescue => e
      log_error("::Lita::Handlers::Zabbix::run_monitors has failed (internal loop) (#{e})")
    end
    success
  end

  private

  def validate_datacenter(datacenter:, response:)
    if @clients.key?(datacenter)
      true
    else
      response.reply_with_mention("Sorry, there is no datacenter named #{datacenter}. Try #{@clients.keys.join(", ")}")
      false
    end
  end

  def monitor_zabbix(datacenter)
    zabbixmon = ::Zabbix::Zabbixmon.new(redis: redis,
      zbx_client: @clients[datacenter],
      zbx_username: config.zabbix_user,
      zbx_password: config.zabbix_password,
      datacenter: datacenter,
      log: log)
    log.debug("starting [#{::Zabbix::Zabbixmon::MONITOR_NAME}] Datacenter: #{datacenter}")
    zabbixmon.monitor(config.zabbix_monitor_payload_url,
      config.monitor_retries,
      config.monitor_retry_interval_seconds,
      config.monitor_http_timeout_seconds)
    log.info("[#{::Zabbix::Zabbixmon::MONITOR_NAME}] #{::Zabbix::Zabbixmon::MONITOR_NAME}-#{datacenter} was successful.") if zabbixmon.hard_failure.nil?
    unless zabbixmon.hard_failure.nil?
      monitor_fail_notify(zabbixmon.monitor_name,
        datacenter,
        zabbixmon.hard_failure,
        config.monitor_hipchat_notify,
        config.paging_monitors.include?(zabbixmon.monitor_name)
      )
    end
    zabbixmon.hard_failure.nil? # returns true for success, false for fail
  end

  def build_zabbix_client(datacenter:)
    options = {
      url: config.zabbix_api_url.gsub(/%datacenter%/, datacenter),
      user: config.zabbix_user,
      password: config.zabbix_password
    }

    Zabbix::Client.new(options)
  end

  def parse_options(options)
    Hash[Shellwords.split(options.to_s).map { |o| o.split("=", 2) }]
  end

  def monitor_fail_notify(monitorname, data_center, error_msg, notify_hipchat_channel, alert_pagerduty)
    if alert_pagerduty
      log.info("Paging sequence initiated. Paging pagerduty.")
      page_r_doodie(error_msg, data_center)
    end
    whining = scrub_password("#{monitorname} has encountered an error verifying the status of Zabbix-#{data_center}. Details: #{error_msg}")
    log.info("Telling hipchat channel #{@status_room}: #{whining}: #{error_msg}")
    whining = "@all : #{whining}" if notify_hipchat_channel
    robot.send_message(@status_room, whining)
  end

  def page_r_doodie(message, datacenter)
    begin
      @pager.trigger(message.to_s, incident_key: ::Zabbix::Zabbixmon::INCIDENT_KEY % datacenter) unless message.nil? || datacenter.nil?
      # FYI: everything beyond this line in this function is 'non-happy-path'
      errmsg = "Error sending page: ::Lita::Handlers::Zabbix::PagerFailed (message: #{message}, datacenter=#{datacenter})"
      if message.nil? || datacenter.nil?
        errmsg = "@all : #{errmsg}" if config.monitor_hipchat_notify
        robot.send_message(@status_room, errmsg)
      end
    rescue => e # error and report
      log_error("[lita-zabbix] error sending page: #{e}")
    end
  rescue ::Lita::Handlers::Zabbix::PagerFailed # but consume the error and keep on truckin'
    errmsg = "[lita-zabbix] Error sending page: ::Zabbix::PagerFailed"
    log.error(errmsg)
    errmsg = "@all : #{errmsg}" if config.monitor_hipchat_notify
    robot.send_message(@status_room, errmsg)
  end

  def log_error(msg)
    unless `hostname`.chomp.include?("internal.salesforce.com")
      log.error(scrub_password(msg))
    end
  end

  def scrub_password(str)
    if config.zabbix_password.empty?
      str
    else
      str.gsub(config.zabbix_password, "****")
    end
  end
end
