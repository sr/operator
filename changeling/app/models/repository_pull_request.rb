# -*- coding: utf-8 -*-
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

  def reload
    @multipass.reload

    if @github_repository.respond_to?(:reload)
      @github_repository.reload
    end

    self
  end

  def number
    @multipass.pull_request_number
  end

  def repository_full_name
    "#{github_repository.owner}/#{github_repository.name}"
  end

  def repository_organization
    github_repository.owner
  end

  def repository_owners_files
    github_repository.repository_owners_files
  end

  def repository_name
    github_repository.name
  end

  def repository_url
    url = URI(@multipass.reference_url)
    url.path = url.path.split("/")[0, 3].join("/")
    url.to_s
  end

  delegate :users, :teams, :owners_files, to: :ownership, prefix: true

  def github_url
    @multipass.reference_url
  end

  def synchronize(create_github_status: true)
    if @multipass.new_record?
      raise ArgumentError, "can not synchronize unsaved multipass record"
    end

    synchronize_github_pull_request
    synchronize_change_categorization
    synchronize_emergency_ticket

    if !@multipass.merged?
      synchronize_github_reviewers
      synchronize_github_statuses
      synchronize_ticket
    end

    @multipass.complete = @multipass.complete?
    @multipass.save!

    if @multipass.affects_default_branch? && github_repository.compliance_enabled?
      if create_github_status
        create_github_commit_status
      end

      update_github_comment
    end

    set_github_labels

    @multipass
  end

  def referenced_ticket
    if @multipass.story_ticket_reference
      @multipass.story_ticket_reference.ticket
    end
  end

  private

  def ownership
    PullRequestOwnership.new(@multipass, self, github_client)
  end

  MAGIC_HTML_COMMENT = "<!-- compliance -->".freeze

  def update_github_comment
    comments = github_client.issue_comments(
      repository.name_with_owner,
      number
    )

    compliance_comment = comments.detect do |comment|
      if comment.user.login != Changeling.config.github_service_account_username
        next
      end

      comment.body.include?(MAGIC_HTML_COMMENT)
    end

    if !compliance_comment
      new_comment = github_client.add_comment(
        repository.name_with_owner,
        number,
        compliance_comment_body_html
      )

      return @multipass.update!(github_comment_id: new_comment.id)
    end

    if compliance_comment.body != compliance_comment_body_html
      return github_client.update_comment(
        repository.name_with_owner,
        compliance_comment.id,
        compliance_comment_body_html
      )
    end
  end

  GLYPH_SCROLL = "📜".freeze
  GLYPH_APPROVED = "👍".freeze
  GLYPH_NOT_APPROVED = "❓".freeze
  GLYPH_COMPLETE = "✅".freeze
  GLYPH_PENDING = "⏲".freeze
  GLYPH_FAILED = "🚫".freeze

  def compliance_comment_body_html
    if ownership_teams.size <= 0
      raise Repository::OwnersError, "could not determine any owner for this change"
    end

    body = "#{MAGIC_HTML_COMMENT}\n"

    if referenced_ticket
      case referenced_ticket.tracker
      when Ticket::TRACKER_JIRA
        label = "#{GLYPH_SCROLL} #{referenced_ticket.external_id} #{referenced_ticket.summary}"
      when Ticket::TRACKER_GUS
        label = "#{GLYPH_SCROLL} #{referenced_ticket.external_id}"
      else
        raise "unhandleable ticket: #{referenced_ticket.inspect}"
      end

      body << "<a href=\"#{referenced_ticket.url}\">#{label}</a>"
    end

    body << "<p>This pull request requires peer review and approval from a member of the following team(s):</p>"
    body << "<ul>"

    ownership_teams.each do |team|
      approver = ownership.approver(team.slug)
      if approver
        body << "<li>#{GLYPH_APPROVED} #{team.html_link}: approved by #{approver.html_link}"
      else
        body << "<li>#{GLYPH_NOT_APPROVED} #{team.html_link}</li>"
      end
    end

    if @multipass.sre_approval_required?
      sre_team = GithubTeam.new(Changeling.config.sre_team_slug)
      body << "<li>#{@multipass.sre_approved? ? GLYPH_APPROVED : GLYPH_NOT_APPROVED} #{sre_team.html_link} (required because this is a #major change)</li>"
    end

    body << "</ul>"

    if !@multipass.sre_approval_required?
      body << "<p>If this is a major change where SRE assistance would be beneficial, please tag it as `#major` in an issue comment.</p>"
    end

    body << "<details>"
    body << "<summary>Peer review and compliance details</summary>"

    if @multipass.complete?
      body << "<p>#{GLYPH_COMPLETE} This pull request meets all compliance requirements and is ready to be merged into the main branch:</p>"
    else
      body << "<p>#{@multipass.pending? ? GLYPH_PENDING : GLYPH_FAILED} This pull request does not yet meet all compliance requirements:</p>"
    end
    body << @multipass.status_description_html

    body << "<p>Reviewers were automatically determined based on the following <code>OWNERS</code> files:</p>"
    body << "<ul>"

    ownership_owners_files.each do |owner_file|
      body << "<li><a href=\"#{owner_file.url}\"><code>#{owner_file.path_name}</code></a></li>"
    end

    body << "</ul>"
  end

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
    @multipass.merged_at = pull_request[:merged_at]
    @multipass.merge_commit_sha = pull_request[:merge_commit_sha] if pull_request[:merged]
    @multipass.title = pull_request[:title]
    @multipass.body = pull_request[:body].to_s
    @multipass.affects_default_branch = (pull_request[:base][:ref] == pull_request[:base][:repo][:default_branch])
    @multipass.release_id = pull_request[:head][:sha]

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

  def synchronize_change_categorization
    if !github_repository.compliance_enabled?
      return
    end

    if @multipass.change_type == ChangeCategorization::EMERGENCY || (@multipass.affects_default_branch? && @multipass.merged? && !@multipass.complete?)
      change_type = ChangeCategorization::EMERGENCY
    else
      comment_bodies = [@multipass.body]
      comment_bodies += github_client.issue_comments(repository.name_with_owner, number)
        .reject { |c| bot_comment?(c) }
        .map { |c| c[:body] }

      # Changes by default are standard, but can be moved to major by adding a
      # hashtag to a pull request comment
      if comment_bodies.any? { |body| ChangeCategorization::MAJOR_COMMENT_MATCHER =~ body }
        change_type = ChangeCategorization::MAJOR
      else
        change_type = ChangeCategorization::STANDARD
      end
    end

    @multipass.change_type = change_type
  end

  def synchronize_emergency_ticket
    if !github_repository.compliance_enabled?
      return
    end

    if @multipass.change_type != ChangeCategorization::EMERGENCY
      return
    end

    ticket = EmergencyMergeTicket.new(
      Changeling.config.jira_client,
      github_repository.github_client,
      Changeling.config.emergency_ticket_jira_project_key,
      @multipass
    )
    ticket.synchronize
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
      repository_id: github_repository.id,
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
    required_statuses = github_repository.repository_commit_statuses.where(
      sha: @multipass.release_id,
      context: github_repository.config.required_testing_statuses
    ).all.to_a

    if required_statuses.length < github_repository.config.required_testing_statuses.length
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
    if @multipass.story_ticket_reference
      @multipass.story_ticket_reference.destroy!
    end
  end

  def update_ticket_reference(ticket)
    if ticket.new_record?
      raise ArgumentError, "ticket is a new record"
    end

    if !@multipass.story_ticket_reference
      @multipass.create_story_ticket_reference!(ticket_id: ticket.id)
    else
      @multipass.story_ticket_reference.update!(ticket_id: ticket.id)
    end
  end

  def create_github_commit_status
    if @multipass.complete?
      @multipass.approve_github_commit_status!
    elsif @multipass.pending?
      @multipass.pending_github_commit_status!
    else
      @multipass.failure_github_commit_status!
    end
  end

  def set_github_labels
    label_names = github_client.labels_for_issue(repository_full_name, number)
      .map { |l| l[:name] }

    ChangeCategorization.change_types.each do |change_type|
      if label_names.include?(change_type) && @multipass.change_type != change_type
        github_client.remove_label(repository_full_name, number, change_type)
      elsif change_type != ChangeCategorization::STANDARD && !label_names.include?(change_type) && @multipass.change_type == change_type
        github_client.add_labels_to_an_issue(repository_full_name, number, [change_type])
      end
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

  def github_repository
    return @github_repository if defined?(@github_repository)

    if !@multipass.github_repository
      Raven.extra_context multipass_id: @multipass.id
      raise ActiveRecord::RecordNotFound, "multipass does not have an associated repository"
    end

    @github_repository = @multipass.github_repository
  end

  def repository
    @multipass.repository
  end

  def bot_comment?(comment)
    # sa- is Pardot convention for 'service account'
    comment[:user][:login].start_with?("sa-")
  end
end
