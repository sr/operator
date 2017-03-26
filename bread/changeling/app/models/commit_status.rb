# The object extracted from a webhook call for statuses.
class CommitStatus
  VALID_CONTEXTS = [
    "ci/circleci",
    "continuous-integration/travis-ci/push",
    "continuous-integration/travis-ci/pr"
  ].freeze

  def initialize(args = {})
    @args = args
  end

  def update_multipass_testing
    return unless valid_context?
    return unless multipass
    multipass.audit_comment = "API: Updated from status event"
    multipass.update(testing: testing_success?)
  end

  def multipass
    @multipass ||= Multipass.find_by(release_id: sha)
  end

  def testing_success?
    state == "success"
  end

  def valid_context?
    VALID_CONTEXTS.include? context
  end

  def sha
    @args["commit"]["sha"]
  end

  def state
    @args["state"]
  end

  def context
    @args["context"]
  end
end
