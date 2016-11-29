class JIRAIssueEvent
  class InvalidPayloadError < StandardError
    def initialize(payload)
      @payload = payload

      super "received an invalid payload"
    end

    attr_reader :payload
  end

  class UnprocessableEvent < StandardError
    def initialize(event_name)
      super "unprocessable webhook event: #{event_name.inspect}"
    end
  end

  PROCESSABLE_EVENT_TYPES = ["jira:issue_created", "jira:issue_updated"].freeze

  def self.parse(payload)
    if !PROCESSABLE_EVENT_TYPES.include?(payload["webhookEvent"])
      raise UnprocessableEvent, payload["webhookEvent"]
    end

    event = new(payload["issue"])

    if !event.valid?
      raise InvalidPayloadError, payload
    end

    event
  end

  def initialize(issue)
    @issue = issue
  end

  def valid?
    @issue.present? &&
      @issue["key"].present? &&
      @issue["fields"].present? &&
      @issue["fields"]["summary"].present? &&
      @issue["fields"]["status"].present?
  end

  def issue_key
    @issue.fetch("key")
  end

  def issue_status
    fields.fetch("status").fetch("name")
  end

  def issue_summary
    fields.fetch("summary")
  end

  private

  def fields
    @issue.fetch("fields")
  end
end
