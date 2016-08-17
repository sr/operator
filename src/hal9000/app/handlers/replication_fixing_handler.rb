class ReplicationFixingHandler < ApplicationHandler
  config :repfix_url, default: "https://repfix-%datacenter%.pardot.com"
  config :datacenters, default: %w[dfw phx]
  config :default_datacenter, default: "dfw"
  config :status_room, default: "1_ops@conf.btf.hipchat.com"
  config :replication_room, default: "1_ops-replication@conf.btf.hipchat.com"
  config :pager, default: "pagerduty"
  config :pagerduty_service_key

  http.get "/replication/_ping", :ping
  http.post "/replication/errors", :create_replication_error

  # http://rubular.com/r/Aos770vcM3
  route /^ignore\s+(?:(?<prefix>db|whoisdb)-)?(?<shard_id>\d+)(?:-(?<datacenter>\S+))?(?:\s+(?<minutes>\d+))?/i, :create_ignore, command: true, help: {
    "ignore SHARD_ID" => "Ignores db-SHARD_ID for 15 minutes in the default datacenter",
    "ignore PREFIX-SHARD_ID" => "Ignores PREFIX-SHARD_ID for 15 minutes (PREFIX is, e.g., db or whoisdb)",
    "ignore PREFIX-SHARD_ID-DATACENTER" => "Ignores PREFIX-SHARD_ID-DATACENTER for 15 minutes (PREFIX is, e.g., db or whoisdb)",
    "ignore SHARD_ID MINUTES" => "Ignores db-SHARD_ID for MINUTES minutes",
    "ignore PREFIX-SHARD_ID MINUTES" => "Ignores PREFIX-SHARD_ID in the default datacenter for MINUTES minutes",
    "ignore PREFIX-SHARD_ID-DATACENTER MINUTES" => "Ignores PREFIX-SHARD_ID-DATACENTER for MINUTES minutes"
  }

  route /^resetignore\s+(?:(?<prefix>db|whoisdb)-)?(?<shard_id>\d+)(?:-(?<datacenter>\S+))?/i, :reset_ignore, command: true, help: {
    "resetignore SHARD_ID" => "Stops ignoring db-SHARD_ID in the default datacenter",
    "resetignore PREFIX-SHARD_ID" => "Stops ignoring PREFIX-SHARD_ID (PREFIX is, e.g., db or whoisdb)",
    "resetignore PREFIX-SHARD_ID-DATACENTER" => "Stops ignoring PREFIX-SHARD_ID-DATACENTER (PREFIX is, e.g., db or whoisdb)"
  }

  # http://rubular.com/r/oud5IU1fji
  route /^fix\s+(?:(?<prefix>db|whoisdb)-)?(?<shard_id>\d+)(?:-(?<datacenter>\S+))?/i, :create_fix, command: true, help: {
    "fix SHARD_ID" => "Attempts to fix db-SHARD_ID in the default datacenter",
    "fix PREFIX-SHARD_ID" => "Attempts to fix PREFIX-SHARD_ID in the default datacenter (PREFIX is, e.g., db or whoisdb)",
    "fix PREFIX-SHARD_ID-DATACENTER" => "Attempts to fix PREFIX-SHARD_ID-DATACENTER"
  }

  route /^cancelfix\s+(?<shard_id>\d+)(?:-(?<datacenter>\S+))?/, :cancel_fix, command: true, help: {
    "cancelfix SHARD_ID" => "Cancels the fix for SHARD_ID in the default datacenter",
    "cancelfix SHARD_ID-DATACENTER" => "Cancels the fix for SHARD_ID-DATACENTER"
  }

  route /^current(?:auto)?fixes/i, :current_fixes, command: true, help: {
    "currentfixes" => "Lists ongoing replication fixes"
  }

  route /^stopfixing/i, :stop_fixing, command: true, help: {
    "stopfixing" => "Globally pauses fixing of replication errors"
  }

  route /^startfixing(?:\s+(?<datacenter>\S+))?/i, :start_fixing, command: true, help: {
    "startfixing" => "Globally starts fixing of replication errors in the default datacenter",
    "startfixing DATACENTER" => "Globally starts fixing of replication errors in DATACENTER"
  }

  route /^checkfixing(?:\s+(?<datacenter>\S+))?/i, :check_fixing, command: true, help: {
    "checkfixing" => "Reports whether fixing is globally enabled or disabled in the default datacenter",
    "checkfixing DATACENTER" => "Reports whether fixing is globally enabled or disabled in DATACENTER"
  }

  route /^status\s+(?:(?<prefix>db|whoisdb)-)?(?<shard_id>\d+)(?:-(?<datacenter>\S+))?/i, :status, command: true, help: {
    "status SHARD_ID" => "Reports the status of db-SHARD_ID in the default datacenter",
    "status PREFIX-SHARD_ID" => "Reports the status of PREFIX-SHARD_ID (PREFIX is, e.g., db or whoisdb)",
    "status PREFIX-SHARD_ID-DATACENTER" => "Reports the status of PREFIX-SHARD_ID-DATACENTER"
  }

  def initialize(robot)
    super

    @throttler = ::ReplicationFixing::MessageThrottler.new(robot: robot, redis: redis)
    @sanitizer = ::ReplicationFixing::ReplicationErrorSanitizer.new

    @pager = \
      case config.pager.to_s
      when "pagerduty"
        ::ReplicationFixing::PagerdutyPager.new(config.pagerduty_service_key)
      when "test"
        ::ReplicationFixing::TestPager.new
      else
        raise ArgumentError, "unknown pager type: #{config.pager}"
      end

    @alerting_manager = ::ReplicationFixing::AlertingManager.new(
      pager: @pager,
      log: log,
    )

    @ignore_clients = ::ReplicationFixing::DatacenterAwareRegistry.new
    @fixing_status_clients = ::ReplicationFixing::DatacenterAwareRegistry.new
    @fixing_clients = ::ReplicationFixing::DatacenterAwareRegistry.new
    @monitor_supervisors = ::ReplicationFixing::DatacenterAwareRegistry.new

    config.datacenters.each do |datacenter|
      ignore_client = ::ReplicationFixing::IgnoreClient.new(datacenter, redis)
      @ignore_clients.register(datacenter, ignore_client)

      fixing_status_client = ::ReplicationFixing::FixingStatusClient.new(datacenter, redis)
      @fixing_status_clients.register(datacenter, fixing_status_client)

      fixing_client = ::ReplicationFixing::FixingClient.new(
        repfix_url: config.repfix_url.gsub("%datacenter%", datacenter),
        fixing_status_client: fixing_status_client,
        log: log,
      )
      @fixing_clients.register(datacenter, fixing_client)

      monitor_supervisor = ::ReplicationFixing::MonitorSupervisor.new(
        redis: redis,
        fixing_client: fixing_client
      )
      @monitor_supervisors.register(datacenter, monitor_supervisor)
    end

    @status_room = ::Lita::Source.new(room: config.status_room)
    @replication_room = ::Lita::Source.new(room: config.replication_room)
  end

  on(:connected) do
    robot.join(config.status_room)
    robot.join(config.replication_room)
  end

  def ping(_request, response)
    response.status = 200
    response.body << ""
  end

  def create_replication_error(request, response)
    body = request.POST
    if body["hostname"]
      begin
        hostname = ::ReplicationFixing::Hostname.new(body["hostname"])
        shard = hostname.shard

        ignore_client = @ignore_clients.for_datacenter(shard.datacenter)
        ignoring = ignore_client.ignoring?(shard)
        if ignoring
          log.debug("Shard is ignored: #{shard}")

          count = ignore_client.incr_skipped_errors_count
          if (count % 200).zero?
            @throttler.send_message(@status_room, "@here FYI: Replication fixing has been stopped, but I've seen about #{result.skipped_errors_count} go by.")
            @alerting_manager.notify_replication_disabled_but_many_errors
          end
        else
          error = body["error"].to_s
          unless error.empty?
            robot.send_message(@replication_room, "#{hostname}: #{body["error"]}")
          end

          mysql_last_error = body["mysql_last_error"].to_s
          unless mysql_last_error.empty?
            sanitized_error = @sanitizer.sanitize(mysql_last_error)
            robot.send_message(@replication_room, "#{hostname}: #{sanitized_error}")
          end

          fixing_client = @fixing_clients.for_datacenter(hostname.datacenter)
          result = fixing_client.fix(shard: hostname)
          @alerting_manager.ingest_fix_result(shard_or_hostname: hostname, result: result)

          case result
          when ::ReplicationFixing::FixingClient::NoErrorDetected
            # This generally means there was an error, but it's not a replication statement issue
            @throttler.send_message(@status_room, "/me is noticing a potential issue with #{hostname}: #{body["error"]}")
          else
            reply_with_fix_result(shard: shard, result: result)
            ensure_monitoring(shard: shard)
          end
        end

        response.status = 201
      rescue ::ReplicationFixing::Hostname::MalformedHostname
        response.status = 400
        response.body << JSON.dump("error" => "malformed hostname")
      rescue ::ReplicationFixing::DatacenterAwareRegistry::NoSuchDatacenter => e
        response.status = 400
        response.body << JSON.dump("error" => e.to_s)
      end
    else
      response.status = 400
      response.body << JSON.dump("error" => "hostname missing")
    end
  end

  def create_ignore(response)
    shard_id = response.match_data["shard_id"].to_i
    prefix = response.match_data["prefix"] || "db"
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    minutes = (response.match_data["minutes"] || "15").to_i

    shard = ::ReplicationFixing::Shard.new(prefix, shard_id, datacenter)
    begin
      ignore_client = @ignore_clients.for_datacenter(shard.datacenter)
      ignore_client.ignore(shard, expire: minutes * 60)
      response.reply_with_mention("OK, I will ignore #{shard} for #{minutes} minutes")
    rescue => e
      response.reply_with_mention("Sorry, something went wrong: #{e}")
    end
  end

  def create_fix(response)
    shard_id = response.match_data["shard_id"].to_i
    prefix = response.match_data["prefix"] || "db"
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    shard = ::ReplicationFixing::Shard.new(prefix, shard_id, datacenter)

    ignore_client = @ignore_clients.for_datacenter(shard.datacenter)
    ignore_client.reset_ignore(shard)
    fixing_client = @fixing_clients.for_datacenter(shard.datacenter)
    result = fixing_client.fix(shard: shard)

    case result
    when ::ReplicationFixing::FixingClient::NoErrorDetected
      response.reply_with_mention "I didn't detect any errors detected on #{shard}"
    when ::ReplicationFixing::FixingClient::NotFixable
      response.reply_with_mention "Sorry, I'm afraid I can't do that. I need a human to resolve errors on #{shard}."
    when ::ReplicationFixing::FixingClient::FixInProgress
      ongoing_minutes = ((Time.now - result.started_at) / 60.0).to_i
      if ongoing_minutes <= 0
        response.reply_with_mention "OK, I'm trying to fix #{shard}"
      else
        response.reply_with_mention "Hmm, I've already been trying to fix #{shard} for #{ongoing_minutes.to_i} minutes now"
      end
    when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
      response.reply_with_mention "Sorry, I got an error while checking fixability: #{result.error}"
    else
      response.reply_with_mention "Sorry, I got an unknown result: #{result}"
    end

    ensure_monitoring(shard: shard)
  rescue ::ReplicationFixing::DatacenterAwareRegistry::NoSuchDatacenter => e
    response.reply_with_mention "Sorry, #{e}"
  end

  def cancel_fix(response)
    shard_id = response.match_data["shard_id"].to_i
    prefix = "db" # TODO: Apparently there is no way to cancel a fix on a specific prefix in rep_fix
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    shard = ::ReplicationFixing::Shard.new(prefix, shard_id, datacenter)

    fixing_client = @fixing_clients.for_datacenter(shard.datacenter)
    result = fixing_client.cancel(shard: shard)

    if result.success?
      response.reply_with_mention "OK, I cancelled all the fixes for #{shard}"
    else
      response.reply_with_mention "Sorry, I wasn't able to cancel the fixes for #{shard}: #{result.message}"
    end
  rescue ::ReplicationFixing::DatacenterAwareRegistry::NoSuchDatacenter => e
    response.reply_with_mention "Sorry, #{e}"
  end

  def reset_ignore(response)
    shard_id = response.match_data["shard_id"].to_i
    prefix = response.match_data["prefix"] || "db"
    datacenter = response.match_data["datacenter"] || config.default_datacenter

    shard = ::ReplicationFixing::Shard.new(prefix, shard_id, datacenter)
    begin
      ignore_client = @ignore_clients.for_datacenter(shard.datacenter)
      ignore_client.reset_ignore(shard)
      response.reply_with_mention("OK, I will no longer ignore #{shard}")
    rescue => e
      response.reply_with_mention("Sorry, something went wrong: #{e}")
    end
  end

  def current_fixes(response)
    fixes = config.datacenters.flat_map { |datacenter| @fixing_status_clients.for_datacenter(datacenter).current_fixes }
    if !fixes.empty?
      response.reply_with_mention("I'm currently fixing: #{fixes.map { |f| f.shard.to_s }.join(", ")}")
    else
      response.reply_with_mention("I'm not fixing anything right now")
    end
  rescue => e
    response.reply_with_mention("Sorry, something went wrong: #{e}")
  end

  def stop_fixing(response)
    config.datacenters.each do |datacenter|
      ignore_client = @ignore_clients.for_datacenter(datacenter)
      ignore_client.ignore_all
    end

    response.reply_with_mention("OK, I've stopped fixing replication for ALL shards")
  rescue => e
    response.reply_with_mention("Sorry, something went wrong: #{e}")
  end

  def start_fixing(response)
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    begin
      ignore_client = @ignore_clients.for_datacenter(datacenter)
      ignore_client.reset_ignore_all
      response.reply_with_mention("OK, I've started fixing replication")
    rescue => e
      response.reply_with_mention("Sorry, something went wrong: #{e}")
    end
  end

  def check_fixing(response)
    datacenter = response.match_data["datacenter"] || config.default_datacenter
    begin
      ignore_client = @ignore_clients.for_datacenter(datacenter)
      if ignore_client.ignoring_all?
        response.reply_with_mention("(nope) Replication fixing is globally disabled in #{datacenter}")
      else
        response.reply_with_mention("(goodnews) Replication fixing is globally enabled in #{datacenter}")
      end
    rescue => e
      response.reply_with_mention("Sorry, something went wrong: #{e}")
    end
  end

  def status(response)
    shard_id = response.match_data["shard_id"].to_i
    prefix = response.match_data["prefix"] || "db"
    datacenter = response.match_data["datacenter"] || config.default_datacenter

    shard = ::ReplicationFixing::Shard.new(prefix, shard_id, datacenter)
    fixing_client = @fixing_clients.for_datacenter(shard.datacenter)
    result = fixing_client.status(shard_or_hostname: shard)
    case result
    when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
      response.reply_with_mention("Sorry, something went wrong: #{result.error}")
    else
      status = result.status
      lines = []
      lines << "status for #{shard}"
      lines << "[fix in progress]" if result.is_a?(::ReplicationFixing::FixingClient::FixInProgress)
      status.fetch("hosts", []).each do |host|
        line = "* #{host["host"]}: #{host["lag"]} seconds behind"
        line << " [erroring]" if host["is_erroring"]
        line << " [fixable]" if host["is_fixable"]
        lines << line
      end

      response.reply(lines.join("\n"))
    end
  rescue ::ReplicationFixing::DatacenterAwareRegistry::NoSuchDatacenter => e
    response.reply_with_mention "Sorry, #{e}"
  end

  private

  def reply_with_fix_result(shard:, result:)
    ignore_client = @ignore_clients.for_datacenter(shard.datacenter)
    ignoring = ignore_client.ignoring?(shard)
    if ignoring
      log.debug("Shard is ignored: #{shard}")
    else
      case result
      when ::ReplicationFixing::FixingClient::NoErrorDetected
        @throttler.send_message(@status_room, "(successful) Replication is fixed on #{shard}")
      when ::ReplicationFixing::FixingClient::NotFixable
        @throttler.send_message(@status_room, "(failed) Replication is broken on #{shard}, but I'm not able to fix it")
      when ::ReplicationFixing::FixingClient::FixInProgress
        ongoing_minutes = (Time.now - result.started_at) / 60.0
        if ongoing_minutes >= 10.0
          @alerting_manager.notify_fixing_a_long_while(shard: shard, started_at: result.started_at)
          @throttler.send_message(@status_room, "(failed) I've been trying to fix replication on #{shard} for #{ongoing_minutes.to_i} minutes now")
        else
          @throttler.send_message(@status_room, "/me is fixing replication on #{shard} (ongoing for #{ongoing_minutes.to_i} minutes)")
        end
      when ::ReplicationFixing::FixingClient::FixableErrorOccurring
        @throttler.send_message(@status_room, "/me is noticing a fixable replication error on #{shard}")
      when ::ReplicationFixing::FixingClient::ErrorCheckingFixability
        @throttler.send_message(@status_room, "/me is getting an error while trying to check the fixability of #{shard}: #{result.error}")
      else
        log.error("Got unknown response from client: #{result}")
      end
    end
  end

  def ensure_monitoring(shard:)
    monitor = ::ReplicationFixing::Monitor.new(shard: shard, tick: 30)
    monitor.on_tick do |result|
      reply_with_fix_result(shard: shard, result: result)
    end
    monitor.on_replication_fixed do |_result|
      begin
        fixing_status_client = @fixing_status_clients.for_datacenter(shard.datacenter)
        fixing_status_client.reset(shard: shard)
      rescue => e
        log.error("Unable to reset status: #{e}")
      end
    end

    monitor_supervisor = @monitor_supervisors.for_datacenter(shard.datacenter)
    monitor_supervisor.start_exclusive_monitor(monitor)
  end
end
