class RepositoryPullRequest
  def self.synchronize(commit_status)
    # Avoid infinite loop where reporting our own status triggers this job
    # again and again.
    return if commit_status.context == Changeling.config.compliance_status_context

    Multipass.where(release_id: commit_status.sha).each do |multipass|
      multipass.synchronize
    end
  end

  def initialize(multipass)
    if multipass.nil? || multipass.new_record?
      raise ArgumentError, "multipass is nil or is a new record"
    end

    @multipass = multipass
  end

  def title
    @multipass.title
  end

  def number
    @multipass.pull_request_number
  end

  def repository_name
    @multipass.repository_name.split("/").last
  end

  def repository_url
    url = URI(@multipass.reference_url)
    url.path = url.path.split("/")[0, 3].join("/")
    url.to_s
  end

  def github_url
    @multipass.reference_url
  end

  def synchronize
    synchronize_github_pull_request
    unless @multipass.merged?
      synchronize_github_statuses
      synchronize_jira_ticket
    end

    @multipass.save!
    @multipass
  end

  def referenced_ticket
    if referenced_ticket_id
      Ticket.where(external_id: referenced_ticket_id, tracker: Ticket::TRACKER_JIRA).first
    end
  end

  private

  def synchronize_github_pull_request
    pull_request = @multipass.github_client.pull_request(
      repository.name_with_owner,
      number
    )

    @multipass.merged = pull_request[:merged]
    @multipass.title = pull_request[:title]
    @multipass.release_id = \
      if pull_request[:merged]
        pull_request[:merge_commit_sha]
      else
        pull_request[:head][:sha]
      end
  end

  def synchronize_github_statuses
    combined_status = @multipass.github_client.combined_status(
      repository.name_with_owner,
      @multipass.release_id
    )

    combined_status[:statuses].each do |payload|
      status = Clients::GitHub::CommitStatus.new(
        combined_status[:repository][:id],
        combined_status[:sha],
        payload[:context],
        payload[:state],
      )

      update_commit_status(status)
    end

    recalculate_testing_status
  end

  def update_commit_status(commit_status)
    attributes = {
      github_repository_id: commit_status.repository_id,
      sha: commit_status.sha,
      context: commit_status.context
    }

    ActiveRecord::Base.transaction do
      status = RepositoryCommitStatus.find_by(attributes)

      if status
        status.update!(state: commit_status.state)
      else
        RepositoryCommitStatus.create!(attributes.merge(state: commit_status.state))
      end
    end
  end

  def synchronize_jira_ticket
    if !referenced_ticket_id
      remove_ticket_reference
      return false
    end

    ticket = Ticket.synchronize_jira_ticket(referenced_ticket_id)
    if ticket
      update_ticket_reference(ticket)
    else
      remove_ticket_reference
    end
  end

  def recalculate_testing_status
    commit_statuses = RepositoryCommitStatus.where(sha: @multipass.release_id)

    success = repository.required_testing_statuses.all? do |context|
      status = commit_statuses.where(context: context).first

      if status
        status.state == RepositoryCommitStatus::SUCCESS
      else
        false
      end
    end

    @multipass.testing = success
  end

  def remove_ticket_reference
    if @multipass.ticket_reference
      @multipass.ticket_reference.destroy!
    end
  end

  def update_ticket_reference(ticket)
    if ticket.new_record?
      raise ArgumentError, "ticket is a new record"
    end

    if !@multipass.ticket_reference
      TicketReference.create!(multipass_id: @multipass.id, ticket_id: ticket.id)
    else
      @multipass.ticket_reference.update!(ticket_id: ticket.id)
    end
  end

  def referenced_ticket_id
    case @multipass.title
    when /\A\[?([A-Z]+\-[0-9]+)\]?/
      Regexp.last_match(1)
    end
  end

  def repository
    @multipass.repository
  end
end
