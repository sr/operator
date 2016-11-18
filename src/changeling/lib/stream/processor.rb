module Stream
  # A class to read from and dispatch events from the heroku streaming API
  class Processor
    def self.run
      new.run
    end

    def run
      read_from_stream
    rescue Tonitrus::Errors::DisconnectedError => error
      sleep 2
      log_error(error)
      retry
    rescue Tonitrus::Errors::Error => error
      log_error(error)
    end

    private

    def read_from_stream
      client.consume do |event, state|
        Stream::Event.new(event.body).call
        self.tonitrus_state = state
      end
    end

    def tonitrus_state
      redis.get("tonitrus-offset-state") || Tonitrus::Offset.newest
    end

    def tonitrus_state=(value)
      redis.set("tonitrus-offset-state", value)
    end

    def redis
      @redis ||= Redis.new(url: ENV["REDIS_URL"])
    end

    def client
      @client ||= Tonitrus::Client.new(
        authentication: authentication,
        env: environment,
        offset: tonitrus_state,
        stream: "api-events"
      )
    end

    def authentication
      ENV.values_at("TONITRUS_LOGIN", "TONITRUS_PASSWORD").join(":")
    end

    def environment
      ENV.fetch("TONITRUS_ENVIRONMENT") { "staging" }
    end

    def log_error(error)
      Rails.logger.info "ERROR: #{error.message}"
      error_name = error.message.split("::").last.underscore
      Librato.increment("tonitrus.error.#{error_name}")
    end
  end
end
