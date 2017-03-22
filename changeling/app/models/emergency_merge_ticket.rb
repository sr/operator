class EmergencyMergeTicket
  class Error < StandardError
  end

  def initialize(jira_client, github_client, pagerduty_service_key, project_key, multipass)
    @jira_client = jira_client
    @github_client = github_client
    @pagerduty_service_key = pagerduty_service_key
    @project_key = project_key
    @multipass = multipass
  end

  def synchronize
    if !@multipass.merge_commit_sha
      raise Error, "multipass does not have a merge commit"
    end

    if !merge_commit
      raise Error, "unable to load merge commit from github"
    end

    jira_issue.save!(attributes)
    ticket = Ticket.synchronize_jira_ticket(jira_issue.key)

    if !@multipass.emergency_ticket_reference
      @multipass.create_emergency_ticket_reference!(ticket: ticket)
      notify_pager(ticket)
    end
  end

  private

  def summary
    "Review Emergency Break Fix (EBF) on repository #{repository_full_name}"
  end

  def description
    <<EOS
The following pull request was merged into the main branch of the #{repository_full_name} repository but did not meet all compliance requirements:

#{@multipass.reference_url}

The merge was performed by #{merge_commit.commit.author.email} on #{merge_commit.commit.author.date.iso8601}.

The use of the EBF process must be documented (root cause, related tickets, ...) within 3 business days. Please refer to the Change Management documentation for further details:

https://sfdc.co/pardot-change-management
EOS
  end

  def merge_author
    merge_commit.commit.author.email || merge_commit.commit.author.login
  end

  def merge_commit
    @merge_commit ||= @github_client.commit(
      repository_full_name,
      @multipass.merge_commit_sha
    )
  end

  def repository_full_name
    @multipass.github_repository.full_name
  end

  def attributes
    {
      "fields": {
        "summary": summary,
        "description": description,
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

  def notify_pager(ticket)
    return unless @pagerduty_service_key

    Clients::Pagerduty.new.trigger(
      service_key: @pagerduty_service_key,
      incident_key: ["ebf", ticket.external_id].join(":"),
      description: summary,
      contexts: [
        Clients::Pagerduty::Link.new("Ticket (#{ticket.external_id})", ticket.url)
      ]
    )
  rescue => e
    Raven.capture_exception(e)
  end
end
