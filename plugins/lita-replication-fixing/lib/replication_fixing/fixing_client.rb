require "faraday"

module ReplicationFixing
  class FixingClient
    ShardIsIgnored = Struct.new(:ignore_count)
    NoErrorDetected = Struct.new(:status)
    ErrorCheckingFixability = Struct.new(:error, :status)

    def initialize(repfix_url:, ignore_client:, repfix_api_key: ENV["REPFIX_API_KEY"])
      @repfix_url = repfix_url
      @ignore_client = ignore_client

      @repfix = Faraday.new(url: @repfix_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def fix(hostname)
      if @ignore_client.ignoring?(hostname.shard_id)
        # TODO: count
        return ShardIsIgnored.new(0)
      else
        response = @repfix.get("/replication/fixes/for/#{hostname.prefix}/#{hostname.shard_id}/#{hostname.datacenter}")
        if response.status == 200
          begin
            json = JSON.parse(response.body)
            if json["error"]
              ErrorCheckingFixability.new(json["error"], {})
            elsif json["is_erroring"] && json["is_fixable"]
              execute_fix(hostname)
            elsif json["is_erroring"]
              ErrorCheckingFixability.new("not fixable", json)
            else !json["is_erroring"]
              NoErrorDetected.new(json)
            end
          rescue JSON::ParserError
            ErrorCheckingFixability.new("invalid JSON response from repfix")
          end
        end
      end
    end

    private
    def execute_fix(hostname)
    end
  end
end
