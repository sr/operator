# Server represents a server where code is deployed for a given target.
class Server < ApplicationRecord
  # A hostname must be in a format where we can extract a datacenter from it
  HOSTNAME_REGEX = /\A\S+-(?<datacenter>[0-9a-z]+)(?:\.dev)?\z/i

  validates :hostname, presence: true, uniqueness: true, format: HOSTNAME_REGEX
  attr_readonly :hostname

  before_save :calculate_datacenter

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

  def calculate_datacenter
    HOSTNAME_REGEX =~ hostname
    datacenter = Regexp.last_match(:datacenter)

    if datacenter =~ /\A[sd][0-9]+\z/ # legacy app-s1, app-d1
      self.datacenter = "softlayer"
    else
      self.datacenter = datacenter
    end
  end
end
