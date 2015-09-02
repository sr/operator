# Server represents a server where code is deployed for a given target.
#
# At this time, `Server` specifically represents a server where code is _pulled_
# via `pull_agent`. Servers where code is _pushed_ are stored in `sync_scripts`.
# As `sync_scripts` becomes deprecated, eventually all servers where code is
# deployed will be a `Server` instance.
class Server < ActiveRecord::Base
  validates :hostname, presence: true, uniqueness: true

  scope :enabled, -> { where(enabled: true) }

  def self.for_repo(repo)
    joins(:repos).where(repos: {id: repo.id})
  end
end
