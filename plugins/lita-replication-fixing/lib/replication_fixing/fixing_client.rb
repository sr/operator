require "faraday"

module ReplicationFixing
  class FixingClient
    NoErrorDetected = Struct.new(:status)
    NotFixable = Struct.new(:status)
    FixInProgress = Struct.new(:started_at)
    FixableErrorOccurring = Struct.new(:status)
    ErrorCheckingFixability = Struct.new(:error)

    def initialize(repfix_url:, fixing_status_client:, log:)
      @repfix_url = repfix_url
      @fixing_status_client = fixing_status_client
      @log = log

      @repfix = Faraday.new(url: @repfix_url, ssl: {verify: true}) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def status(shard_or_hostname:)
      path = "/replication/fixes/for/#{shard_or_hostname.prefix}/#{shard_or_hostname.shard_id}"
      path += "/#{shard_or_hostname.datacenter}" if shard_or_hostname.respond_to?(:datacenter)

      response = @repfix.get(path)
      if response.status == 200
        begin
          json = JSON.parse(response.body)
          if json["error"]
            ErrorCheckingFixability.new(json["message"])
          elsif json["fix"] && json["fix"]["active"]
            begin
              @fixing_status_client.ensure_fixing_status_ongoing(shard_or_hostname.shard_id)
            rescue => e
              @log.error("Unable to keep state about fix: #{e}")
            end

            current_status = @fixing_status_client.status(shard_or_hostname.shard_id)
            FixInProgress.new(current_status.started_at)
          elsif json["is_erroring"] && json["is_fixable"]
            FixableErrorOccurring.new(json)
          elsif json["is_erroring"]
            begin
              @fixing_status_client.reset_status(shard_or_hostname.shard_id)
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
        ErrorCheckingFixability.new("HTTP #{response.code} status code from repfix: #{response.body}")
      end
    rescue => e
      ErrorCheckingFixability.new("error checking fixability: #{e}")
    end

    def fix(shard_or_hostname:, user: "system")
      result = status(shard_or_hostname: shard_or_hostname)
      if result.kind_of?(FixableErrorOccurring)
        execute_fix(shard_or_hostname: shard_or_hostname, user: user)
      else
        result
      end
    end

    private
    def execute_fix(shard_or_hostname:, user:)
      response = @repfix.post("/replication/fix/#{shard_or_hostname.prefix}/#{shard_or_hostname.shard_id}", user: user)
      if response.status == 200
        begin
          json = JSON.parse(response.body)
          if json["error"]
            ErrorCheckingFixability.new(json["message"])
          else
            begin
              @fixing_status_client.ensure_fixing_status_ongoing(shard_or_hostname.shard_id)
            rescue => e
              @log.error("Unable to keep state about fix: #{e}")
            end

            status(shard_or_hostname: shard_or_hostname)
          end
        rescue JSON::ParserError
          ErrorCheckingFixability.new("invalid JSON response from repfix: #{response.body}")
        end
      else
        ErrorCheckingFixability.new("HTTP #{response.code} status code from repfix: #{response.body}")
      end
    rescue => e
      ErrorCheckingFixability.new("error checking fixability: #{e}")
    end
  end
end
