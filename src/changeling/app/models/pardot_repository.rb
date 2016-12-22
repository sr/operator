class PardotRepository
  # TODO(sr) Move the configuration somewhere to allow setting this up
  # cleanly in tests without needing to have a magic heroku/changeling
  # repository configured here.
  CHANGELING = "heroku/changeling".freeze

  BREAD = "Pardot/bread".freeze
  CHEF = "Pardot/chef".freeze
  PARDOT = "Pardot/pardot".freeze
  TEAM_OPS = "Pardot/ops".freeze
  TEAM_DEVELOPERS = "Pardot/developers".freeze

  def initialize(nwo)
    @name_with_owner = nwo
  end

  attr_reader :name_with_owner

  def required_testing_statuses
    case name_with_owner
    when BREAD
      ["BREAD build"]
    when CHANGELING
      ["ci/bazel", "ci/travis"]
    when CHEF
      ["Test Jobs"]
    when PARDOT
      ["Test Jobs"]
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
    if Changeling.config.pardot_rollout_phase1_enabled?
      [BREAD, PARDOT, CHEF].include?(name_with_owner)
    else
      [BREAD, CHANGELING].include?(name_with_owner)
    end
  end

  # Do not create commit statuses for now.
  def update_github_commit_status?
    if Changeling.config.pardot_rollout_phase1_enabled?
      [BREAD, PARDOT, CHEF].include?(name_with_owner)
    else
      [BREAD].include?(name_with_owner)
    end
  end

  def participating?
    true
  end
end
