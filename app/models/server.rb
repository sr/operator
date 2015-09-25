# Server represents a server where code is deployed for a given target.
#
# At this time, `Server` specifically represents a server where code is _pulled_
# via `pull_agent`. Servers where code is _pushed_ are stored in `sync_scripts`.
# As `sync_scripts` becomes deprecated, eventually all servers where code is
# deployed will be a `Server` instance.
class Server < ActiveRecord::Base
  validates :hostname, presence: true, uniqueness: true
  attr_readonly :hostname

  scope :enabled, -> { where(enabled: true) }

  has_many :deploy_scenarios
  accepts_nested_attributes_for :deploy_scenarios, allow_destroy: true

  def self.for_repo(repo)
    joins(:repos).where(repos: {id: repo.id})
  end

  def repos
    deploy_scenarios.includes(:repo).map(&:repo).uniq
  end
end
