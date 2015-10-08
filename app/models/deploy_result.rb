class DeployResult < ActiveRecord::Base
  belongs_to :deploy
  belongs_to :server

  STAGES = %w(initiated deployed completed failed)
  validates :stage,
    presence: true,
    inclusion: {in: STAGES}

  scope :incomplete, -> { where("stage NOT IN (?)", ["completed", "failed"]) }

  STAGES.each do |stage|
    define_method("#{stage}?") { self.stage == stage }
  end
end
