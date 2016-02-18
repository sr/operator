require "faraday"

module ReplicationFixing
  class FixingClient
    NoErrorDetected = Struct.new(:status)
    ShardIsIgnored = Class.new
    AllShardsIgnored = Struct.new(:skipped_errors_count)
    NotFixable = Struct.new(:status)
    FixInProgress = Struct.new(:started_at)
    FixableErrorOccurring = Struct.new(:status)
    ErrorCheckingFixability = Struct.new(:error)

    def initialize(repfix_url:, ignore_client:, fixing_status_client:, log:)
      @repfix_url = repfix_url
      @ignore_client = ignore_client
      @fixing_status_client = fixing_status_client
      @log = log

      @repfix = Faraday.new(url: @repfix_url, ssl: {verify: false}) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def status(hostname:)
      response = @repfix.get("/replication/fixes/for/#{hostname.prefix}/#{hostname.shard_id}/#{hostname.datacenter}")
      if response.status == 200
        begin
          json = JSON.parse(response.body)
          if json["error"]
            ErrorCheckingFixability.new(json["error"])
          elsif json["fix"] && json["fix"]["active"]
            begin
              @fixing_status_client.ensure_fixing_status_ongoing(hostname.shard_id)
            rescue => e
              @log.error("Unable to keep state about fix: #{e}")
            end

            current_status = @fixing_status_client.status(hostname.shard_id)
            FixInProgress.new(current_status.started_at)
          elsif json["is_erroring"] && json["is_fixable"]
            FixableErrorOccurring.new(json)
          elsif json["is_erroring"]
            begin
              @fixing_status_client.reset_status(hostname.shard_id)
            rescue => e
              @log.error("Unable to reset status: #{e}")
            end

            NotFixable.new(json)
          else !json["is_erroring"]
            NoErrorDetected.new(json)
          end
        rescue JSON::ParserError
          ErrorCheckingFixability.new("invalid JSON response from repfix: #{response.body}")
        end
      else
        ErrorCheckingFixability.new("non-200 status code from repfix: #{response.body}")
      end
    end

    def fix(hostname:, user: "system", monitor_only: false)
      ignoring = @ignore_client.ignoring?(hostname.shard_id)
      if ignoring == :shard
        ShardIsIgnored.new
      elsif ignoring == :all
        AllShardsIgnored.new(@ignore_client.incr_skipped_errors_count)
      else result = status(hostname: hostname)
        if result.kind_of?(FixableErrorOccurring)
          if monitor_only
            result
          else
            execute_fix(hostname: hostname, user: user)
          end
        else
          result
        end
      end
    end

    private
    def execute_fix(hostname:, user:)
      response = @repfix.post("/replication/fix/#{hostname.prefix}/#{hostname.shard_id}", user: user)
      if response.status == 200
        begin
          json = JSON.parse(response.body)
          if json["error"]
            ErrorCheckingFixability.new(json["error"])
          else
            begin
              @fixing_status_client.ensure_fixing_status_ongoing(hostname.shard_id)
            rescue => e
              @log.error("Unable to keep state about fix: #{e}")
            end

            status(hostname: hostname)
          end
        rescue JSON::ParserError
          ErrorCheckingFixability.new("invalid JSON response from repfix: #{response.body}")
        end
      else
        ErrorCheckingFixability.new("non-200 status code from repfix: #{response.body}")
      end
    end

    def build_incident_key(hostname:)
      ["replication-error", hostname.to_s].join("/")
    end
  end
end
