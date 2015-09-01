class DeployResult < ActiveRecord::Base
  belongs_to :deploy
  belongs_to :server

  STATUSES = %w(pending complete failed)
  validates :status,
    presence: true,
    inclusion: {in: STATUSES}
end
