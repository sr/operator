# Server represents a server where code is deployed for a given target.
class Server < ApplicationRecord
  validates :hostname, presence: true, uniqueness: true
  attr_readonly :hostname

  scope :enabled, -> { where(enabled: true) }
  scope :active, -> { where(archived: false) }

  has_many :deploy_scenarios
  accepts_nested_attributes_for :deploy_scenarios, allow_destroy: true

  has_many :projects, -> { uniq }, through: :deploy_scenarios

  has_many :server_taggings, dependent: :destroy
  has_many :server_tags, through: :server_taggings

  def self.for_project(project)
    joins(:projects).where(projects: { id: project.id })
  end

  def server_tag_names=(tag_names)
    self.server_tags = tag_names.reject(&:blank?).map { |tag_name|
      ServerTag.find_or_create_by(name: tag_name)
    }
  end

  def server_tag_names
    server_tags.map(&:name)
  end

  def datacenter
    case hostname
    when /-dfw$/ then :dfw
    when /-phx$/ then :phx
    else :sl
    end
  end
end
