require "faraday"

module ReplicationFixing
  class FixingClient
    NoErrorDetected = Struct.new(:status)
    NotFixable = Struct.new(:status)
    FixInProgress = Struct.new(:status, :started_at)
    FixableErrorOccurring = Struct.new(:status)
    ErrorCheckingFixability = Struct.new(:error)

    CancelResult = Struct.new(:success?, :message)

    def initialize(repfix_url:, fixing_status_client:, log:)
      @repfix_url = repfix_url
      @fixing_status_client = fixing_status_client
      @log = log

      options = {
        url: @repfix_url,
        ssl: { verify: true }
      }

      proxy = ENV.fetch("HAL9000_HTTP_PROXY", nil)
      if proxy
        options[:proxy] = { uri: proxy }
      end

      @repfix = Faraday.new(options) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def status(shard_or_hostname:)
      path = "/replication/fixes/for/#{shard_or_hostname.prefix}/#{shard_or_hostname.shard_id}"
      if shard_or_hostname.respond_to?(:cluster_id)
        path += "/#{shard_or_hostname.cluster_id}" if shard_or_hostname.cluster_id
      end

      response = @repfix.get(path)
      if response.status == 200
        begin
          json = JSON.parse(response.body)

          begin
            if json["is_erroring"]
              @fixing_status_client.set_active(
                shard:  shard_or_hostname,
                active: (json["fix"] && json["fix"]["active"]),
              )
            else
              @fixing_status_client.reset(shard: shard_or_hostname)
            end
          rescue => e
            @log.error("Unable to keep state about fix: #{e}")
          end

          if json["error"]
            ErrorCheckingFixability.new(json["message"])
          elsif json["fix"] && json["fix"]["active"]
            current_status = @fixing_status_client.status(shard: shard_or_hostname)
            FixInProgress.new(json, current_status.started_at)
          elsif json["is_erroring"] && json["is_fixable"]
            FixableErrorOccurring.new(json)
          elsif json["is_erroring"]
            NotFixable.new(json)
          else
            NoErrorDetected.new(json)
          end
        rescue JSON::ParserError
          ErrorCheckingFixability.new("invalid JSON response from repfix: #{response.body}")
        end
      else
        ErrorCheckingFixability.new("HTTP #{response.status} status code from repfix: #{response.body}")
      end
    rescue => e
      ErrorCheckingFixability.new("error checking fixability: #{e}")
    end

    def fix(shard:, user: "system")
      result = status(shard_or_hostname: shard)
      if result.is_a?(FixableErrorOccurring)
        execute_fix(shard: shard, user: user)
      else
        result
      end
    end

    def cancel(shard:)
      response = @repfix.post("/replication/fixes/cancel/#{shard.shard_id}")
      if response.status == 200
        begin
          json = JSON.parse(response.body)

          if json["is_canceled"]
            begin
              @fixing_status_client.reset(shard: shard)
            rescue => e
              log.error("Unable to reset status: #{e}")
            end
          end

          CancelResult.new(json["is_canceled"], json["message"])
        rescue JSON::ParserError
          CancelResult.new(false, "invalid JSON response from repfix: #{response.body}")
        end
      else
        CancelResult.new(false, "HTTP #{response.status} status code from repfix: #{response.body}")
      end
    rescue => e
      CancelResult.new(false, e.to_s)
    end

    private

    def execute_fix(shard:, user:)
      response = @repfix.post("/replication/fix/#{shard.prefix}/#{shard.shard_id}", user: user)
      if response.status == 200
        begin
          json = JSON.parse(response.body)
          if json["error"]
            ErrorCheckingFixability.new(json["message"])
          else
            status(shard_or_hostname: shard)
          end
        rescue JSON::ParserError
          ErrorCheckingFixability.new("invalid JSON response from repfix: #{response.body}")
        end
      else
        ErrorCheckingFixability.new("HTTP #{response.status} status code from repfix: #{response.body}")
      end
    rescue => e
      ErrorCheckingFixability.new("error checking fixability: #{e}")
    end
  end
end
