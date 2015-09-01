class DeployResult < ActiveRecord::Base
  belongs_to :deploy
  belongs_to :server

  STATUSES = %w(pending completed failed)
  validates :status,
    presence: true,
    inclusion: {in: STATUSES}

  scope :pending, -> { where(status: "pending") }
end
