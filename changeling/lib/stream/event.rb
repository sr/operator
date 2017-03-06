module Stream
  # An event from the heroku streaming API
  class Event
    attr_reader :event
    def initialize(event)
      @event = event
    end

    def call
      return unless release_create?
      return unless heroku_employee?
      StreamEventJob.perform_later(event)
    end

    def release_create?
      event["action"] == "create" && event["resource"] == "release"
    end

    def user
      event["data"] && event["data"]["user"]
    end

    def heroku_employee?
      user && user["email"] =~ /@heroku.com$/
    end

    private

    def app_name
      event
        .fetch("data", {})
        .fetch("app", {})
        .fetch("name", "")
    end
  end
end
