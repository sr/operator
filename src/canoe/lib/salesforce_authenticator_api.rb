require "oauth"

class SalesforceAuthenticatorAPI
  class RequestFailed < StandardError
    def initialize(response)
      super "Request failed with status #{response.code.inspect} and body #{response.body.inspect}"
    end
  end

  class Fake
    def create_pairing(_username, _phrase)
      Response.new(fake_response(id: SecureRandom.uuid))
    end

    def pairing_status(_pairing_id)
      Response.new(fake_response(enabled: true))
    end

    def initiate_authentication(_pairing_id)
      Response.new(fake_response)
    end

    def authentication_status(_request_id)
      @authentication_status ||
        Response.new(fake_response(granted: true))
    end

    def authentication_status=(data)
      @authentication_status = Response.new(fake_response(data))
    end

    private

    HTTPResponse = Struct.new(:code, :body)

    def fake_response(body = {})
      HTTPResponse.new("200", JSON.dump(body))
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

  HEADERS = {
    "Accept": "application/json",
    "Content-Type" => "application/json"
  }.freeze

  def initialize(id, key)
    @consumer = OAuth::Consumer.new(id, key)
  end

  def create_pairing(username, phrase)
    response = access_token.post(
      BASE_URL + "/pairings/create",
      { user_name: username, pairing_phrase: phrase },
      HEADERS,
    )

    Response.new(response)
  end

  def pairing_status(pairing_id)
    if pairing_id.to_s.empty?
      raise ArgumentError, "malformed pairing_id: #{pairing_id.inspect}"
    end

    response = access_token.get(BASE_URL + "/pairings/#{pairing_id}", HEADERS)

    Response.new(response)
  end

  def initiate_authentication(pairing_id)
    if pairing_id.to_s.empty?
      raise ArgumentError, "malformed pairing_id: #{pairing_id.inspect}"
    end

    response = access_token.post(
      BASE_URL + "/authentication_requests/initiate",
      { pairing_id: pairing_id },
      HEADERS
    )

    Response.new(response)
  end

  def authentication_status(request_id)
    if request_id.to_s.empty?
      raise ArgumentError, "malformed authentication request_id: #{request_id.inspect}"
    end

    response = access_token.get(BASE_URL + "/authentication_requests/#{request_id}", HEADERS)

    Response.new(response)
  end

  private

  def access_token
    @access_token ||= OAuth::AccessToken.new(@consumer)
  end
end
