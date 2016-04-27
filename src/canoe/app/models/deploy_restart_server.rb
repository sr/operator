class DeployRestartServer < ActiveRecord::Base
  belongs_to :deploy
  belongs_to :server
end
