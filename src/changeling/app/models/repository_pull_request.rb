class RepositoryPullRequest
  TICKET_REFERENCE_REGEXP = /\A\[?([A-Z]+\-[0-9]+)\]?/
  GUS_TICKET_ID_PREFIX = "W-".freeze

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

  def repository_full_name
    @multipass.repository_name
  end

  def repository_organization
    @multipass.repository_name.split("/").first
  end

  def repository_name
    @multipass.repository_name.split("/").last
  end

  def repository_url
    url = URI(@multipass.reference_url)
    url.path = url.path.split("/")[0, 3].join("/")
    url.to_s
  end

  # Returns an Array of all the OWNERS files covering files being changed in
  # this pull request
  def owners_files
    files = Set.new([])
    directories = {}

    repository.owners_files.each do |file|
      directories[File.dirname(file.path_name)] = file
    end

    if directories.empty?
      return []
    end

    # If the pull request doesn't have any change, return the root OWNERS file,
    # or an empty Array if there is none
    if @multipass.changed_files.empty?
      return Array(directories["/"])
    end

    @multipass.changed_files.each do |file|
      file.ascend do |path|
        dirname = path.dirname.to_s

        if directories.key?(dirname)
          files.add(directories.fetch(dirname))
        end
      end
    end

    files.to_a
  end

  # Return the Array of team members, one per OWNERS file that is relevant to
  # the files changed in this pull request
  def owners
    # Cache of all GitHub teams and their members referenced across OWNERS files
    github_team_ids = {}
    github_teams = {}

    # Fetch all teams for this repository's organization
    github_client.organization_teams(repository_organization).each do |team|
      github_team_ids["#{repository_organization}/#{team.slug}"] = team.id
    end

    # Parse all OWNERS files and for load the referenced teams and their members,
    # returning the resulting nested Array.
    owners_files.map do |file|
      file = OwnersFile.new(file.content)
      users = Set.new([])

      # Load the referenced teams and their members
      file.teams.each do |team|
        # Ignore teams that don't belong to this repository's organization
        if !github_team_ids.key?(team)
          next
        end

        # Avoid fetching members of the same team twice
        if github_teams.key?(team)
          users.merge(github_teams.fetch(team))

          next
        end

        members = Set.new([])

        github_client.team_members2(github_team_ids.fetch(team)).each do |user|
          members.add(user.login)
        end

        github_teams[team] = members
        users.merge(members)
      end

      users.to_a
    end
  end

  def github_url
    @multipass.reference_url
  end

  def synchronize
    if @multipass.new_record?
      raise ArgumentError, "can not synchronize unsaved multipass record"
    end

    synchronize_github_pull_request

    if !@multipass.merged?
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

    files = github_client.pull_request_files(
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

    PullRequestFile.transaction do
      PullRequestFile.where(multipass_id: @multipass.id).delete_all

      files.each do |file|
        pull_request_file = PullRequestFile.find_or_initialize_by(
          multipass_id: @multipass.id,
          filename: "/" + file.filename,
          state: file.status,
          patch: file.patch || ""
        )
        pull_request_file.save
      end
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
    github_reviews = github_client.pull_request_reviews(
      repository.name_with_owner,
      number
    )

    reviews = PeerReview.synchronize(@multipass, github_reviews)
    approval = reviews.detect { |r| r.state == Clients::GitHub::REVIEW_APPROVED }

    if approval
      @multipass.peer_reviewer = approval.reviewer_github_login
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
      if referenced_ticket_id[0, 2] == GUS_TICKET_ID_PREFIX
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
    required_statuses = RepositoryCommitStatus.where(
      sha: @multipass.release_id,
      context: repository.required_testing_statuses
    ).to_a

    if required_statuses.length < repository.required_testing_statuses.length
      # At least one required status hasn't been reported yet
      @multipass.testing = false
      @multipass.tests_state = RepositoryCommitStatus::PENDING
    else
      @multipass.testing = true
      if required_statuses.any? { |r| r.state == RepositoryCommitStatus::PENDING }
        @multipass.tests_state = RepositoryCommitStatus::PENDING
      elsif required_statuses.all? { |r| r.state == RepositoryCommitStatus::SUCCESS }
        @multipass.tests_state = RepositoryCommitStatus::SUCCESS
      else
        @multipass.tests_state = RepositoryCommitStatus::FAILURE
      end
    end
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
    case @multipass.title.lstrip
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
