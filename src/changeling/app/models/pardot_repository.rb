class PardotRepository
  # TODO(sr) Move the configuration somewhere to allow setting this up
  # cleanly in tests without needing to have a magic heroku/changeling
  # repository configured here.
  CHANGELING = "heroku/changeling".freeze

  ANSIBLE = "Pardot/ansible".freeze
  BLUE_MESH = "Pardot/blue-mesh".freeze
  BREAD = "Pardot/bread".freeze
  CHEF = "Pardot/chef".freeze
  INTERNAL_API = "Pardot/internal-api".freeze
  MESH = "Pardot/mesh".freeze
  MURDOC = "Pardot/murdoc".freeze
  PARDOT = "Pardot/pardot".freeze
  TEAM_OPS = "Pardot/ops".freeze
  TEAM_DEVELOPERS = "Pardot/developers".freeze
  TEST_STATUS = "Test Jobs".freeze
  FINAL_STATUS = "Final Jobs".freeze

  COMPLIANT_REPOSITORIES = [ANSIBLE, BLUE_MESH, BREAD, CHEF, INTERNAL_API, MESH, MURDOC, PARDOT].freeze

  def initialize(nwo)
    @name_with_owner = nwo
  end

  attr_reader :name_with_owner

  def required_testing_statuses
    case name_with_owner
    when ANSIBLE, BLUE_MESH, BREAD, INTERNAL_API, MESH, MURDOC
      [TEST_STATUS]
    when CHEF, PARDOT
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
    COMPLIANT_REPOSITORIES.include?(name_with_owner)
  end

  def participating?
    true
  end
end
