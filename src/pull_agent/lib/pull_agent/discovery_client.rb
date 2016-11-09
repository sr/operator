require "net/http"
require "uri"

module PullAgent
  class DiscoveryClient
    class Error < StandardError
      attr_reader :response

      def initialize(response)
        super("Unable to communicate with Disco: #{response.body}")
        @response = response
      end
    end

    def initialize
      @uri = URI("http://127.0.0.1:8383")
    end

    def service(service_name)
      service_uri = @uri.dup.tap { |u| u.path = "/v1/service/#{service_name}" }
      response = Net::HTTP.get_response(service_uri)
      if response.is_a?(Net::HTTPOK)
        JSON.parse(response.body)
      else
        raise Error, response
      end
    end
  end
end
