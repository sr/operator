class JIRAIssue
  # Creates a JIRAIssue from the API response in, e.g.,
  # <https://jira.dev.pardot.com/rest/api/latest/issue/PDT-1>
  def initialize(payload = {})
    @payload = payload
  end

  def key
    @payload["key"]
  end

  def summary
    @payload["fields"]["summary"]
  end

  def status
    @payload["fields"]["status"]["name"]
  end

  def open?
    !@payload["fields"]["resolution"]
  end

  def url
    URI.join(Changeling.config.jira_url, "browse", @payload["key"])
  end
end
