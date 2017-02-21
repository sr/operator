class EmergencyMergeTicket
  def initialize(jira_client, project_key, multipass)
    @jira_client = jira_client
    @project_key = project_key
    @multipass = multipass
  end

  def synchronize
    jira_issue.save!(attributes)
    ticket = Ticket.synchronize_jira_ticket(jira_issue.key)

    if !@multipass.emergency_ticket_reference
      @multipass.create_emergency_ticket_reference!(ticket: ticket)
    end
  end

  private

  def summary
    "TODO"
  end

  def description
    "TODO"
  end

  def attributes
    {
      "fields": {
        "summary": "TODO",
        "description": "TODO",
        "project": {
          "key": @project_key
        },
        "issuetype": {
          "name": "Task"
        }
      }
    }
  end

  def jira_issue
    @jira_issue ||=
      if @multipass.emergency_ticket_reference
        @jira_client.Issue.find(@multipass.emergency_ticket_reference.ticket.external_id)
      else
        @jira_client.Issue.build
      end
  end
end
