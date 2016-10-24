require "oauth"

class SalesforceAuthenticatorAPI
  class RequestFailed < StandardError
    def initialize(response)
      super "Request failed with status #{response.code.inspect} and body #{response.body.inspect}"
    end
  end

  class Response
    OK = "200".freeze

    def initialize(response)
      @response = response
    end

    def success?
      @response.code == OK
    end

    def error_message
      parsed["error_message"]
    end

    def [](key)
      parsed[key]
    end

    private

    def parsed
      @parsed ||= JSON.parse(@response.body)
    end
  end

  BASE_URL = "https://login.salesforce.com/services/verify/v1".freeze
  JSON_CONTENT_TYPE = "application/json".freeze

  def initialize(id, key)
    @consumer = OAuth::Consumer.new(id, key)
  end

  def create_pairing(username, phrase)
    response = access_token.post(
      BASE_URL + "/pairings/create",
      { user_name: username, pairing_phrase: phrase },
      { "Content-Type" => JSON_CONTENT_TYPE, "Accept" => JSON_CONTENT_TYPE }
    )

    Response.new(response)
  end

  private

  def access_token
    @access_token ||= OAuth::AccessToken.new(@consumer)
  end
end
