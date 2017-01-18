class PardotComplianceStatus
  def initialize(multipass)
    @multipass = multipass
    @default = HerokuComplianceStatus.new(multipass)
  end

  delegate \
    :complete?,
    :rejected?,
    :pending?,
    :emergency_approved?,
    to: :@default

  def complete?
    success = @multipass.missing_mandatory_fields.empty? && \
              peer_reviewed? && \
              tests_successful?

    unless @multipass.merged?
      success &= !ticket_reference_missing? && referenced_ticket_open?
    end

    success
  end

  def user_is_peer_reviewer?(user)
    @default.user_is_peer_reviewer?(user)
  end

  def sre_approved?
    false
  end

  def user_is_sre_approver?(_user)
    raise NotImplementedError
  end

  def user_is_emergency_approver?(user)
    @default.user_is_emergency_approver?(user)
  end

  def user_is_rejector?(user)
    @default.user_is_rejector?(user)
  end

  def peer_reviewed?
    if !Changeling.config.repository_owners_review_required.include?(@multipass.repository_name)
      return @multipass.peer_reviewer.present?
    end

    reviewers = @multipass.peer_review_approvers
    repository_owners = @multipass.repository_owners
    changed_files = @multipass.changed_files

    # If the repository owners feature is enabled for the repository then it
    # must have an OWNERS file at its root listing the teams that own it. This
    # will eventually be required for all repositories and be enforced via a
    # continuous linting process:
    #
    # https://jira.dev.pardot.com/browse/BREAD-1785
    if repository_owners.empty?
      raise Repository::OwnersError, "the repository does not have any owner"
    end

    # If support for per-directory OWNERS file is not turned on for this repository
    # or if the pull request is empty, then simply check that one of the repository
    # owners have reviewed the PR.
    if !Changeling.config.component_owners_review_enabled.include?(@multipass.repository_name) || changed_files.empty?
      return repository_owners.any? { |owner| reviewers.include?(owner) }
    end

    owners = @multipass.owners

    if owners.empty?
      raise Repository::OwnersError, "could not determine any owner for this change"
    end

    # Returns true if at least one of the owners for each of the affected
    # components have reviewed and approved the pull request.
    owners.all? do |team|
      reviewers.any? { |r| team.include?(r) }
    end
  end

  def github_commit_status_description
    if rejected?
      "Changes requested by #{@multipass.rejector}"
    elsif !peer_reviewed?
      if @multipass.repository_owners_enabled?
        if @multipass.components_owners_enabled?
          "Review by one or more component(s) owner(s) is missing"
        else
          "Peer review by a repository owner is missing"
        end
      else
        "Peer review is required"
      end
    elsif emergency_approved?
      "Satisfied via emergency approval by #{@multipass.emergency_approver}."
    elsif complete?
      "Satisfied. Reviewed by #{@multipass.reviewers}."
    elsif ticket_reference_missing?
      "Ticket reference is missing"
    elsif !referenced_ticket_open?
      "Referenced ticket is not open"
    elsif tests_pending?
      "Awaiting automated tests results"
    elsif !tests_successful?
      "Automated tests failed"
    else
      "Missing fields: #{@multipass.missing_fields.join(", ")}"
    end
  end

  private

  def referenced_ticket_open?
    if !@multipass.repository.ticket_reference_required?
      return true
    end

    if @multipass.referenced_ticket
      @multipass.referenced_ticket.open?
    end
  end

  def ticket_reference_missing?
    if !@multipass.repository.ticket_reference_required?
      return false
    end

    @multipass.referenced_ticket.nil?
  end

  def tests_successful?
    @multipass.tests_state == RepositoryCommitStatus::SUCCESS
  end

  def tests_pending?
    @multipass.tests_state == RepositoryCommitStatus::PENDING
  end
end
