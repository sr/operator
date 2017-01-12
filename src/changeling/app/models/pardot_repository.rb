class PardotRepository
  # TODO(sr) Move the configuration somewhere to allow setting this up
  # cleanly in tests without needing to have a magic heroku/changeling
  # repository configured here.
  CHANGELING = "heroku/changeling".freeze

  ANSIBLE = "Pardot/ansible".freeze
  BLUEMESH = "Pardot/blue-mesh".freeze
  BREAD = "Pardot/bread".freeze
  CHEF = "Pardot/chef".freeze
  PARDOT = "Pardot/pardot".freeze
  TEAM_OPS = "Pardot/ops".freeze
  TEAM_DEVELOPERS = "Pardot/developers".freeze
  TEST_STATUS = "Test Jobs".freeze
  FINAL_STATUS = "Final Jobs".freeze
  COMPLIANT_REPOSITORIES = [ANSIBLE, BLUEMESH, BREAD, CHEF, PARDOT].freeze

  def initialize(nwo)
    @name_with_owner = nwo
  end

  attr_reader :name_with_owner

  def required_testing_statuses
    case name_with_owner
      when ANSIBLE
        [TEST_STATUS]
      when BLUEMESH
        [TEST_STATUS]
      when BREAD
        [TEST_STATUS]
      when CHEF
        [TEST_STATUS, FINAL_STATUS]
      when PARDOT
        [TEST_STATUS, FINAL_STATUS]
      when CHANGELING
        ["ci/bazel", "ci/travis"]
    else
      Rails.logger.info "configuration-missing repo=#{name_with_owner.inspect}"
      []
    end
  end

  def team
    if CHEF
      TEAM_OPS
    else
      TEAM_DEVELOPERS
    end
  end

  def ticket_reference_required?
    true
  end

  # Do not create commit statuses for now.
  def update_github_commit_status?
    if Changeling.config.pardot_rollout_phase1_enabled?
      COMPLIANT_REPOSITORIES.include?(name_with_owner)
    else
      [BREAD].include?(name_with_owner)
    end
  end

  def participating?
    true
  end
end
