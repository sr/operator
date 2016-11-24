class JIRAIssueEvent
  class InvalidPayloadError < StandardError
    def initialize(payload)
      @payload = payload

      super "received an invalid payload"
    end

    attr_reader :payload
  end

  PROCESSABLE_EVENT_TYPES = ["jira:issue_updated"].freeze

  def self.parse(payload)
    if !PROCESSABLE_EVENT_TYPES.include?(payload["webhookEvent"])
      return
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
      @issue["fields"]["summary"].present?
  end

  def issue_key
    @issue["key"]
  end

  def issue_summary
    @issue["fields"]["summary"]
  end
end
