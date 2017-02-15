class ComplianceStatus
  def initialize(multipass)
    @multipass = multipass
    @pull_request = RepositoryPullRequest.new(@multipass)
  end

  def update_complete
    if Changeling.config.pardot?
      return true
    end

    @multipass.complete = complete?
    true
  end

  def complete?
    adapter.complete?
  end

  def rejected?
    adapter.rejected?
  end

  def pending?
    adapter.pending?
  end

  def peer_reviewed?
    adapter.peer_reviewed?
  end

  def user_is_peer_reviewer?(user)
    peer_reviewed? && adapter.user_is_peer_reviewer?(user)
  end

  def sre_approved?
    adapter.sre_approved?
  end

  def user_is_sre_approver?(user)
    sre_approved? && adapter.user_is_sre_approver?(user)
  end

  def emergency_approved?
    adapter.emergency_approved?
  end

  def user_is_emergency_approver?(user)
    emergency_approved? && adapter.user_is_emergency_approver?(user)
  end

  def user_is_rejector?(user)
    rejected? && adapter.user_is_rejector?(user)
  end

  def github_commit_status_description
    adapter.github_commit_status_description
  end

  def description_html
    body = "<ul>"

    teams = @pull_request.ownership_teams.map do |team|
      "<a href=\"#{html_escape(team.url)}\">@#{html_escape(team.slug)}</a>"
    end

    if peer_reviewed?
      approvers = @multipass.peer_review_approvers.map do |approver|
        "<a href=\"#{html_escape(Changeling.config.github_url + "/" + approver)}\">@#{html_escape(approver)}</a>"
      end

      body << "<li>Changes reviewed and approved by the following people: #{approvers.join(" ")}</li>"
    elsif teams.size == 1
      body << "<li>Review by a member of the #{teams[0]} team is required</li>"
    else
      body << "<li>Review by a member of the following teams is required: #{teams.join(" ")}</li>"
    end

    case @multipass.tests_state
    when RepositoryCommitStatus::SUCCESS
      body << "<li>The automated tests have succeeded</li>"
    when RepositoryCommitStatus::PENDING
      body << "<li>The automated tests have not yet completed</li>"
    when RepositoryCommitStatus::FAILURE
      body << "<li>The automated tests have failed</li>"
    else
      body << "<li>The status of automated tests is unknown</li>"
    end

    ticket = @multipass.referenced_ticket

    if ticket
      if ticket.open?
        body << "<li>Ticket reference found: <a href=\"#{html_escape(ticket.url)}\">#{html_escape(ticket.external_id)}</a></li>"
      else
        body << "<li>The referenced ticket (<a href=\"#{html_escape(ticket.url)}\">#{html_escape(ticket.external_id)}</a>) is not open</li>"
      end
    else
      body << "<li>No ticket reference found. Include the ticket ID at the beginning of the pull request title</li>"
    end

    body << "</ul>"
  end

  def status
    if complete?
      "complete"
    elsif pending?
      "pending"
    elsif rejected?
      "rejected"
    else
      "incomplete"
    end
  end

  private

  def html_escape(s)
    ERB::Util.html_escape(s)
  end

  def adapter
    @adapter ||=
      if Changeling.config.pardot?
        PardotComplianceStatus.new(@multipass, @pull_request)
      else
        HerokuComplianceStatus.new(@multipass)
      end
  end
end
