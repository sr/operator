# DeployScenario associates a server with a particular project and target for
# deployment. The server list for a particular deploy is generated by querying
# this model.
class DeployScenario < ActiveRecord::Base
  belongs_to :project
  belongs_to :server
  belongs_to :deploy_target

  validates :server_id,
    uniqueness: {scope: [:project_id, :deploy_target_id]}
end