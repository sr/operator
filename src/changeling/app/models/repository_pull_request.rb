class RepositoryPullRequest
  TICKET_REFERENCE_REGEXP = /\A\[?([A-Z]+\-[0-9]+)\]?/

  def self.synchronize(commit_status)
    # Avoid infinite loop where reporting our own status triggers synchronization
    # again and again
    return if commit_status.context == Changeling.config.compliance_status_context

    Multipass.where(release_id: commit_status.sha).each do |multipass|
      multipass.synchronize
    end
  end

  def initialize(multipass)
    if multipass.nil?
      raise ArgumentError, "multipass is nil"
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
    if @multipass.new_record?
      raise ArgumentError, "can not synchronize unsaved multipass record"
    end

    synchronize_github_pull_request
    unless @multipass.merged?
      synchronize_github_reviewers
      synchronize_github_statuses
      synchronize_ticket
    end

    @multipass.save!
    @multipass
  end

  def referenced_ticket
    if @multipass.ticket_reference
      @multipass.ticket_reference.ticket
    end
  end

  private

  def synchronize_github_pull_request
    pull_request = github_client.pull_request(
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
    combined_status = github_client.combined_status(
      repository.name_with_owner,
      @multipass.release_id
    )

    combined_status[:statuses].each do |payload|
      status = Clients::GitHub::CommitStatus.new(
        combined_status.repository.id,
        combined_status.sha,
        payload.context,
        payload.state,
      )

      update_commit_status(status)
    end

    recalculate_testing_status
  end

  def synchronize_github_reviewers
    reviews = github_client.pull_request_reviews(
      repository.name_with_owner,
      number
    )

    approval = reviews.detect { |r| r.state == Clients::GitHub::REVIEW_APPROVED }

    if approval
      @multipass.peer_reviewer = approval.user.login
    else
      @multipass.peer_reviewer = nil
    end
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
  # rubocop:disable Lint/HandleExceptions
  rescue ActiveRecord::RecordNotUnique
  end

  def synchronize_ticket
    if !referenced_ticket_id
      remove_ticket_reference
      return false
    end

    ticket =
      if referenced_ticket_id[0].casecmp("W") == 0
        summary = title.sub(TICKET_REFERENCE_REGEXP, "").lstrip
        Ticket.synchronize_gus_ticket(referenced_ticket_id, summary)
      else
        Ticket.synchronize_jira_ticket(referenced_ticket_id)
      end

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
    when TICKET_REFERENCE_REGEXP
      Regexp.last_match(1)
    end
  end

  def github_client
    @github_client ||= Clients::GitHub.new(Changeling.config.github_service_account_token)
  end

  def repository
    @multipass.repository
  end
end
