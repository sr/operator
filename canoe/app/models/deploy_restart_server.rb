class DeployRestartServer < ApplicationRecord
  belongs_to :deploy
  belongs_to :server
end
