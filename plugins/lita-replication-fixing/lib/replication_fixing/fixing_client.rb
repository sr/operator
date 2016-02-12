require "faraday"

module ReplicationFixing
  class FixingClient
    NoErrorDetected = Struct.new(:status)
    ShardIsIgnored = Class.new
    AllShardsIgnored = Struct.new(:skipped_errors_count)
    NotFixable = Struct.new(:status)
    ErrorCheckingFixability = Struct.new(:error)
    FixInProgress = Struct.new(:new_fix, :started_at)

    def initialize(repfix_url:, ignore_client:, fixing_status_client:, pager:, log:)
      @repfix_url = repfix_url
      @ignore_client = ignore_client
      @fixing_status_client = fixing_status_client
      @pager = pager
      @log = log

      @repfix = Faraday.new(url: @repfix_url, ssl: {verify: false}) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def fix(hostname:, user: "system")
      ignoring = @ignore_client.ignoring?(hostname.shard_id)
      if ignoring == :shard
        ShardIsIgnored.new
      elsif ignoring == :all
        AllShardsIgnored.new(@ignore_client.incr_skipped_errors_count)
      else
        response = @repfix.get("/replication/fixes/for/#{hostname.prefix}/#{hostname.shard_id}/#{hostname.datacenter}")
        if response.status == 200
          begin
            json = JSON.parse(response.body)
            if json["error"]
              ErrorCheckingFixability.new(json["error"])
            elsif json["is_erroring"] && json["is_fixable"]
              execute_fix(hostname: hostname, fix: json.fetch("fix", {}), user: user)
            elsif json["is_erroring"]
              # TODO: Notify PagerDuty
              # TODO: Reset status
              NotFixable.new(json)
            else !json["is_erroring"]
              NoErrorDetected.new(json)
            end
          rescue JSON::ParserError
            ErrorCheckingFixability.new("invalid JSON response from repfix")
          end
        else
          ErrorCheckingFixability.new("non-200 status code from repfix: #{response.body}")
        end
      end
    end

    private
    def execute_fix(hostname:, fix:, user:)
      @fixing_status_client.ensure_fixing_status_ongoing(hostname.shard_id)
      current_status = @fixing_status_client.status(hostname.shard_id)

      if fix["active"]
        # Rep fix is still trying to fix this
        FixInProgress.new(false, current_status.started_at)
      else
        response = @repfix.post("/replication/fix/#{hostname.prefix}/#{hostname.shard_id}", user: user)
        if response.status == 200
          begin
            json = JSON.parse(response.body)
            if json["error"]
              ErrorCheckingFixability.new(json["error"])
            elsif json["is_erroring"] && json["is_fixable"]
              FixInProgress.new(true, current_status.started_at)
            elsif json["is_erroring"]
              # TODO: Notify PagerDuty
              # TODO: Reset status
              NotFixable.new(json)
            else !json["is_erroring"]
              NoErrorDetected.new(json)
            end
          rescue JSON::ParserError
            ErrorCheckingFixability.new("invalid JSON response from repfix")
          end
        else
          ErrorCheckingFixability.new("non-200 status code from repfix: #{response.body}")
        end
      end
    end

    def send_page(description, incident_key:)
      @pager.trigger(description, incident_key: incident_key)
    rescue => e
      log.error("Unable to dispatch page: #{description}")
    end

    def build_incident_key(hostname:)
      ["replication-error", hostname.to_s].join("/")
    end
  end
end
