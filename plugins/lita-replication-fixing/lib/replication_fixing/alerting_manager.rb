module ReplicationFixing
  # Determines whether to alert a human based on an outcome of the FixingClient
  # API (i.e., rep_fix)
  class AlertingManager
    def initialize(pager:, log:)
      @pager = pager
      @log = log
    end

    def ingest_fix_result(hostname:, result:)
      case result
      when FixingClient::ErrorCheckingFixability
        @pager.trigger("#{hostname}: error checking fixability for #{hostname}: #{result.error}", incident_key: incident_key(hostname))
      when FixingClient::NotFixable
        @pager.trigger("#{hostname}: replication is not automatically fixable", incident_key: incident_key(hostname))
      when FixingClient::AllShardsIgnored
        if (result.skipped_errors_count % 200).zero?
          @pager.trigger("replication fixing is disabled, but many errors are still occurring")
        end
      end
    rescue
      @log.error("Error sending page: #{$!}")
    end

    # Notifies the pager that the bot has been trying to fix replication for
    # long enough that a human will probably need to intervene
    def notify_fixing_a_long_while(hostname:, started_at:)
      minutes_fixing = (Time.now - started_at) / 60
      @pager.trigger("#{hostname}: automatic replication fixing has been going on for #{minutes_fixing.to_i} minutes", incident_key: incident_key(hostname))
    rescue
      @log.error("Error sending page: #{$!}")
    end

    private
    def incident_key(hostname)
      ["replication-error", hostname.to_s].join("/")
    end
  end
end
