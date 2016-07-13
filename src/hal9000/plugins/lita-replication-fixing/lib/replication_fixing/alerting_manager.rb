module ReplicationFixing
  # Determines whether to alert a human based on an outcome of the FixingClient
  # API (i.e., rep_fix)
  class AlertingManager
    def initialize(pager:, log:)
      @pager = pager
      @log = log
    end

    def ingest_fix_result(shard_or_hostname:, result:)
      case result
      when FixingClient::NotFixable
        @pager.trigger("#{shard_or_hostname}: replication is not automatically fixable", incident_key: incident_key(shard_or_hostname))
      end
    rescue => e
      @log.error("Error sending page: #{e}")
    end

    # Notifies the pager that fixing is globally ignored, but a lot of errors
    # are still being noticed
    def notify_replication_disabled_but_many_errors
      @pager.trigger("replication fixing is disabled, but many errors are still occurring", incident_key: "replication/all-shards-ignored")
    end

    # Notifies the pager that the bot has been trying to fix replication for
    # long enough that a human will probably need to intervene
    def notify_fixing_a_long_while(shard:, started_at:)
      minutes_fixing = (Time.now - started_at) / 60
      @pager.trigger("#{shard}: automatic replication fixing has been going on for #{minutes_fixing.to_i} minutes", incident_key: incident_key(shard))
    rescue
      @log.error("Error sending page: #{$!}")
    end

    private

    def incident_key(shard_or_hostname)
      ["replication-error", shard_or_hostname.to_s].join("/")
    end
  end
end
