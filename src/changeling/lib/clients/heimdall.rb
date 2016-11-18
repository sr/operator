# HTTP clients
module Clients
  # Client for interacting with Heimdall.
  class Heimdall
    def client
      @client ||= Faraday.new(url: heimdall_api_url) do |connection|
        connection.headers["Content-Type"] = "application/json"
        connection.headers["Authorization"] = authorization_header
        connection.use ZipkinTracer::FaradayHandler, heimdall_api_host
        connection.adapter Faraday.default_adapter
      end
    end

    def heimdall_api_host
      Addressable::URI.parse(heimdall_api_url).hostname
    end

    def heimdall_api_url
      ENV["HEIMDALL_API_URL"]
    end

    def authorization_header
      "Bearer #{ENV['HEIMDALL_API_TOKEN']}"
    end

    def notify(repo, payload)
      return if ENV["RAILS_ENV"] == "staging"
      repo_name(repo, payload)
      url = "/hubot-deploy/repos/#{repo.name_with_owner}/messages"

      client.post do |request|
        request.url url
        request.body = { type: payload.delete(:type), data: payload }.to_json
        request.options.timeout = 5
        request.options.open_timeout = 2
      end
    rescue Faraday::TimeoutError
      # This will be retried thanks to sidekiq
      {}
    end

    def repo_name(repo, payload)
      raise(MissingRepositoryError, "Can't notify without repo - payload: #{payload}") unless repo
      name = repo.name_with_owner if repo.respond_to?(:name_with_owner)
      raise(MissingRepositoryError, "Can't notify without repo name - payload: #{payload}") unless name
      name
    end

    def apps
      url = "/hubot-deploy/apps"

      response = client.get do |request|
        request.url url
        request.options.timeout = 5
        request.options.open_timeout = 2
      end

      JSON.parse(response.body)
    rescue Faraday::TimeoutError, JSON::ParserError
      {}
    end
  end

  class MissingRepositoryError < ArgumentError; end
end
